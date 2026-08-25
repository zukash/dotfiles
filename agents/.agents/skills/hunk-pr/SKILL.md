---
name: hunk-pr
description: Hunk上でPRの行コメントをagent noteとして確認・合意した後、PRテンプレートに沿ってghコマンドでPRを作成する。
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
7. OK後、テンプレートに沿った本文を用意し、`gh pr create --base <base> --head <head> --title <title> --body-file <file>` でPRを作成する。作成後、PR URLと概要を報告する。

PR作成前に `gh auth status` と対象repoを確認する。テンプレートが見つからない場合は、その旨を明記して標準的な概要を作る。対象hunkがなくなった場合は、別ファイルへ代替noteを付けず、その理由を報告する。
