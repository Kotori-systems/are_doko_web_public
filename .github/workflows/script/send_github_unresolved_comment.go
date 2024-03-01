package main

import (
	"context"
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"os"
	"slices"
	"strconv"
	"strings"

	"github.com/bwmarrin/discordgo"
	"github.com/google/generative-ai-go/genai"
	"github.com/google/go-github/v37/github"
	"github.com/shurcooL/githubv4"
	"github.com/thoas/go-funk"
	"golang.org/x/oauth2"
	"google.golang.org/api/option"
)

const generatedSummaryFile = "generated_summary_file.csv"

type Developer struct {
	// GitHubfユーザー名
	Name string

	// ユーザー名の略語
	NameAbbr string

	// DiscordのユーザーID
	DiscordUserId string
}

type ThreadEdge struct {
	Node struct {
		IsResolved  bool
		IsOutdated  bool
		IsCollapsed bool
		Comments    struct {
			Nodes []struct {
				Author struct {
					Login string
				}
				Body       string
				Url        string
				DatabaseId int
			}
		} `graphql:"comments(first: 100)"`
	}
}

type Query struct {
	Repository struct {
		PullRequest struct {
			ReviewThreads struct {
				Edges []ThreadEdge
			} `graphql:"reviewThreads(first: 100)"`
		} `graphql:"pullRequest(number: $prNumber)"`
	} `graphql:"repository(owner: $repoOwner, name: $repoName)"`
}

type PrReviewThread struct {
	ThreadEdge ThreadEdge
	Summary    string
}

type PullRequestAndQuery struct {
	PullRequest     github.PullRequest
	PrReviewThreads []PrReviewThread
}

type SummaryData struct {
	DatabaseId int
	Summary    string
}

func main() {
	summariesOfYesterday := []SummaryData{}
	summariesOfToday := []SummaryData{}

	// csvファイルから、PRスレッド毎の要約されたコメントを取得する（昨日のバッチでの作成分）
	if _, err := os.Stat(generatedSummaryFile); err == nil {
		file, err := os.Open(generatedSummaryFile)
		if err != nil {
			log.Fatal(err)
		}
		defer file.Close()

		reader := csv.NewReader(file)
		for {
			record, err := reader.Read()
			if err == io.EOF {
				break
			}
			if err != nil {
				log.Fatal(err)
			}

			databaseId, err := strconv.Atoi(record[0])
			if err != nil {
				fmt.Println("databaseId conversion error:", err)
			} else {
				summariesOfYesterday = append(summariesOfYesterday, SummaryData{DatabaseId: databaseId, Summary: record[1]})
			}
		}
	}

	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: os.Getenv("GITHUB_TOKEN")},
	)
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)
	owner := "Kotori-systems"

	// レポジトリのリストを取得する
	opt := &github.RepositoryListByOrgOptions{
		ListOptions: github.ListOptions{PerPage: 100},
	}
	repositories, _, err := client.Repositories.ListByOrg(ctx, owner, opt)
	if err != nil {
		log.Fatal("Error getting repositories:", err.Error())
	}
	var pullRequests []PullRequestAndQuery
	for _, repository := range repositories {
		// 該当レポジトリの、StateがOpenのプルリクエストの一覧を取得して格納しておく
		pulls, _, err := client.PullRequests.List(ctx, owner, *repository.Name, &github.PullRequestListOptions{
			State: "open",
		})
		if err != nil {
			log.Fatal("Error fetching pull requests:", err.Error())
		}
		for _, pull := range pulls {
			if !*pull.Draft { // DraftのPRは対象外
				v4Client := githubv4.NewClient(tc)

				variables := map[string]interface{}{
					"prNumber":  githubv4.Int(*pull.Number),
					"repoOwner": githubv4.String(owner),
					"repoName":  githubv4.String(*pull.Head.Repo.Name),
				}

				var query Query
				err := v4Client.Query(ctx, &query, variables)
				if err != nil {
					log.Fatal("v4Client.Query error:", err)
				}
				var unresolvedReviewThreads []PrReviewThread
				for _, edge := range query.Repository.PullRequest.ReviewThreads.Edges {
					if !edge.Node.IsResolved {
						firstComment := edge.Node.Comments.Nodes[0]
						summary := firstComment.Body
						// 昨日のバッチでの作成分のcsvファイルに要約テキストが存在したら、それをそのまま使う
						found := false
						for _, d := range summariesOfYesterday {
							if d.DatabaseId == firstComment.DatabaseId {
								found = true
								summariesOfToday = append(summariesOfToday, SummaryData{DatabaseId: firstComment.DatabaseId, Summary: d.Summary})
								summary = d.Summary
								log.Printf("already firstComment.DatabaseId:%d summary:%s", firstComment.DatabaseId, summary)
								break
							}
						}

						if !found {
							// 要約したコメントがcsvファイルに存在しなければ、最初のコメントをGemini APIで要約
							summary = summarizeComment(ctx, summary)

							summariesOfToday = append(summariesOfToday, SummaryData{DatabaseId: firstComment.DatabaseId, Summary: summary})
							log.Printf("firstComment.DatabaseId:%d summary:%s", firstComment.DatabaseId, summary)
						}

						prReviewThread := PrReviewThread{
							ThreadEdge: edge,
							Summary:    summary,
						}
						unresolvedReviewThreads = append(unresolvedReviewThreads, prReviewThread)
					}
				}

				prAndQuery := PullRequestAndQuery{
					PullRequest:     *pull,
					PrReviewThreads: unresolvedReviewThreads,
				}
				pullRequests = append(pullRequests, prAndQuery)
			}
		}
	}

	developers := []Developer{
		{Name: "github_demo_user_1", NameAbbr: "鈴", DiscordUserId: "4123421342135342343"},
		{Name: "kouairchair", NameAbbr: "渡", DiscordUserId: "218202482390728705"},
		{Name: "tanakak0827", NameAbbr: "田", DiscordUserId: "218202482390728705"},
	}

	// 使用した要約コメントをcsvファイルに書き込む（上書き）
	file, err := os.Create(generatedSummaryFile)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	writer := csv.NewWriter(file)
	defer writer.Flush()
	for _, d := range summariesOfToday {
		writer.Write([]string{strconv.Itoa(d.DatabaseId), d.Summary})
	}
	writer.Flush()

	for _, developer := range developers {
		var resultMessages []string
		var messagesPerSection []string
		lastRepoName := ""

		// 同メンバーがPRに対して最初にコメントしたものがResolveされてないプルリクエストを抽出
		messagesPerSection = []string{}
		lastRepoName = ""
		lastPullRequestTitle := ""
		developerNames := funk.Map(developers, func(dev Developer) string {
			return dev.Name
		}).([]string)
		for _, pull := range pullRequests {
			threadEdges := pull.PrReviewThreads
			pull := pull.PullRequest
			// レビューコメント
			for _, threadEdge := range threadEdges {
				reviewThread := threadEdge.ThreadEdge
				commentNodes := reviewThread.Node.Comments.Nodes
				firstCommenter := commentNodes[0].Author.Login
				lastCommentNode := commentNodes[len(commentNodes)-1]
				lastCommenter := lastCommentNode.Author.Login
				lastCommentUrl := lastCommentNode.Url
				lastComment := lastCommentNode.Body

				reviewee := *pull.User.Login
				var destinations []string // 通知の宛先
				for _, name := range developerNames {
					if strings.Contains(lastComment, name) {
						// 最後のコメントのメンションを通知の宛先に追加する
						destinations = append(destinations, name)
					}
				}
				containsMention := len(destinations) > 0

				// 最後のコメントがメンション付きだったら、その宛先のみに通知する
				if !containsMention {
					if reviewee == firstCommenter {
						// 最初のコメント者がレビューイ本人の場合は、本人がResolveしていないだけの可能性が高い
						destinations = append(destinations, reviewee)
					} else {
						if firstCommenter == lastCommenter {
							// 最初のコメント者と最後のコメント者が同じ場合

							// レビューイには必ず通知する（レビューイが指摘事項修正していない可能性が高い）
							// TODO: 上記のreviewee == firstCommenterのロジックとまとめられるかも
							destinations = append(destinations, reviewee)

							// 最初のコメント者への通知有無チェック
							// TODO:このロジックは要再検討かも
							shouldNotifyToFirstCommenter := false
							for _, comment := range commentNodes {
								if comment.Author.Login == reviewee {
									// スレッド内にrevieweeのコメントが含まれている場合は最初のコメント者にも通知する（コメント者が単純にResolveし忘れの可能性が高い）
									shouldNotifyToFirstCommenter = true
								}
							}
							if shouldNotifyToFirstCommenter {
								destinations = append(destinations, firstCommenter)
							}

						} else {
							// 最初のコメント者と最後のコメント者が異なる場合は、最初のコメント者とレビューイ両方に通知する（レビューイが修正した内容を最初のコメント者が確認してない場合や最後のコメントがレビューイで「〜修正します」などのコメントの場合があるので両者に通知が必要）
							destinations = append(destinations, reviewee) // TODO: 上記のreviewee == firstCommenterのロジックとまとめられるかも
							destinations = append(destinations, firstCommenter)
						}
					}
				}

				if slices.Contains(destinations, developer.Name) {
					otherDstDevelopers := funk.Filter(developers, func(dev Developer) bool {
						return slices.Contains(destinations, dev.Name) && dev.Name != developer.Name
					}).([]Developer)
					otherDstDeveloperAbbrNames := funk.Map(otherDstDevelopers, func(dev Developer) string {
						return dev.NameAbbr
					}).([]string)
					if *pull.Head.Repo.Name != lastRepoName {
						messagesPerSection = append(messagesPerSection, fmt.Sprintf("- %s", *pull.Head.Repo.Name))
					}
					if *pull.Title != lastPullRequestTitle {
						messagesPerSection = append(messagesPerSection, fmt.Sprintf("  - %s", *pull.Title))
					}
					// 他に通知されたメンバーが誰なのかもメッセージに含める（例：鈴木宛のメッセージの場合、「・〜（+田/渡）」）
					otherDestinationsStr := ""
					if len(otherDstDeveloperAbbrNames) > 0 {
						otherDestinationsStr = "（+" + strings.Join(otherDstDeveloperAbbrNames, "/") + "）"
					}
					messagesPerSection = append(messagesPerSection, fmt.Sprintf("    - [%s](%s)%s", threadEdge.Summary, lastCommentUrl, otherDestinationsStr))
					lastRepoName = *pull.Head.Repo.Name
					lastPullRequestTitle = *pull.Title
				}
			}
		}

		if len(messagesPerSection) > 0 {
			resultMessages = append(resultMessages, fmt.Sprintf("**未マージの各PRでResolveされてないコメント:**\n%s", strings.Join(messagesPerSection, "\n")))
		} else {
			log.Printf("未マージの各PRでResolveされてないコメントはありませんでした（GitHubユーザー:%s、DiscordユーザーID:%s）", developer.Name, developer.DiscordUserId)
		}

		// TODO: 今後、機能拡張はここに実装（例：各開発メンバーがレビュアーかつ未レビューのプルリクエストを抽出する）

		if len(resultMessages) > 0 {
			// Discordのダイレクトメッセージを送信する
			message := strings.Join(resultMessages, "\n")
			err = postToDiscord(message, developer.DiscordUserId, developer.Name)
			if err != nil {
				log.Fatal("Error posting message to Discord:", err.Error())
			}
		}
	}
}

/*
 * コメントをGemini APIで関西弁で要約
 */
func summarizeComment(ctx context.Context, comment string) string {
	apiKey := os.Getenv("GEMINI_API_KEY")
	client, err := genai.NewClient(ctx, option.WithAPIKey(apiKey))
	if err != nil {
		log.Fatal(err)
	}
	defer client.Close()
	model := client.GenerativeModel("models/gemini-pro")
	prompt := fmt.Sprintf("あなたは Geminiによって訓練された言語モデルです。あなたの目的は、非常に経験豊富なソフトウェアエンジニアとして機能し、GitHub上に投稿されたコメントを要約することで、開発者の生産性を高めることです。以下文章がそのコメントですが、20字以内の関西弁の日本語に要約してください。ただ、URLは無視してください（閲覧権限がない場合もあるため）\n\n%s", comment)
	resp, err := model.GenerateContent(ctx, genai.Text(prompt))
	if err != nil {
		log.Printf("gemini-pro error:%s", err)
	} else {
		// Gemini APIの回答をキャストして取得する
		textPart, ok := resp.Candidates[0].Content.Parts[0].(genai.Text)
		if ok {
			return string(textPart)
		}
	}
	return comment
}

func postToDiscord(message string, discordUserId string, githubUserName string) error {
	// Discord の Bot トークンを設定する
	token := os.Getenv("DISCORD_BOT_TOKEN")

	// Discord クライアントを作成
	dg, err := discordgo.New("Bot " + token)
	if err != nil {
		return err
	}

	// メッセージを送信する
	channel, err := dg.UserChannelCreate(discordUserId)
	if err != nil {
		return err
	}
	msg := discordgo.Message{
		Content: message,
	}
	_, err = dg.ChannelMessageSend(channel.ID, msg.Content)
	if err != nil {
		return err
	}

	log.Printf("正常にDiscordに投稿されました（GitHubユーザー:%s、DiscordユーザーID:%s）\nメッセージ:%s", githubUserName, discordUserId, message)

	return nil
}
