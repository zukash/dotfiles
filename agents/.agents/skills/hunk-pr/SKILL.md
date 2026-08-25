---
name: hunk-pr
description: Hunk上でPRの行コメントをagent noteとして確認・合意した後、PRを作成し、承認済みnoteをGitHubの行コメントへ反映する。
---

# Hunk PR

HunkでPRの行コメントを確認してユーザーの合意を得た後、GitHub Pull Requestを作成する。

Hunkの基本操作やコマンド仕様はこのSkillに重複して記載しない。必ず次のコマンドで公式Skillのパスを取得し、そこに記載された操作方法を参照する。

```sh
hunk skill path
```

## Workflow

1. 現在の作業ディレクトリに紐づくHunkセッションを選ぶ。複数候補があり一意に決まらなければ確認し、セッションがなければHunkを起動してもらう。
2. 差分、ユーザーコメント、必要なコンテキスト、現在のブランチとbase branchを確認する。対象範囲が不明な場合は作成を進めない。
3. `hunk session comment clear --repo . --all --yes` でHunk上の既存コメントを全てリセットする。
4. repo内の `.github/PULL_REQUEST_TEMPLATE.md`、`.github/pull_request_template.md`、`.github/PULL_REQUEST_TEMPLATE/` を調べる。なければ `gh api` でrepoとorgの `.github` リポジトリも調べ、見つかったテンプレートの形式に沿ってPR概要を作る。
5. PRで伝えるべき行コメントを整理し、対象hunkへ移動して `hunk session comment add` または `comment apply --stdin` でagent noteとして付与する。付与したnoteをユーザーに提示する。
6. ユーザーから明示的なOKを得るまで停止する。OK前に `gh pr create`、push、PRコメント投稿などの外部操作を行わない。変更依頼があればnoteを更新し、再度合意を得る。
7. OK後、テンプレートに沿った本文を用意し、`gh pr create --base <base> --head <head> --title <title> --body-file <file>` でPRを作成する。作成後、PR番号とhead commitを取得する。
8. 合意済みのagent noteを、作成したPRのGitHub行コメントへ変換する。各noteについて、`gh api --method POST repos/{owner}/{repo}/pulls/{number}/comments` に `body`、`commit_id`、`path`、`line`、`side` を渡して投稿する。新しい行は `side=RIGHT`、削除された行は `side=LEFT` とし、noteの対象行を正確に使う。
9. PR上の行コメント一覧を確認し、投稿できなかったnoteがないこと、PR URL、概要、行コメント数を報告する。

PR作成前に `gh auth status` と対象repoを確認する。テンプレートが見つからない場合は、その旨を明記して標準的な概要を作る。Hunkのagent noteはGitHubへ自動移行されないため、PR作成後の行コメント投稿まで完了させる。対象hunkがなくなった場合は、別ファイルへ代替noteを付けず、その理由を報告する。
