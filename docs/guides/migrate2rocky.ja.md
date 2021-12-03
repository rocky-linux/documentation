---
title: Rocky Linuxへの移行
author: Ezequiel Bruni
contributors: Norio Yahata, Steven Spencer
update: 12-03-2021
---

# CentOS Stream, CentOS, Alma Linux, RHEL, Oracle LinuxからRocky Linuxへの移行方法

## 必要な条件・前提条件

* Centos、Alma Linux、RHEL、Oracle Linuxが動作するハードウェアサーバまたはVPS。現在サポートされているバージョンは8.5です。
* Linuxコマンドラインの知識
* リモートマシンへのSSHの知識
* 少しだけ冒険的な姿勢
* すべてのコマンドはrootで実行する必要があります。rootでログインするか、"sudo" を大量に入力する準備をしてください。


## はじめに

このガイドでは、上記のすべてのディストリビューションを、完全に機能するRocky Linuxに変換する方法を学ぶことができます。これは、Rocky Linuxをインストールするには遠回りな方法ですが、さまざまな状況下でRocky Linuxに移行するためのベストな方法の1つかもしれません。

例えば、サーバープロバイダによっては、しばらくの間、デフォルトでRocky Linuxをサポートしない場合があります。また、運用中の本番環境のサーバにすべてを再インストールせずにRocky Linuxへ移行したいという場合もあるでしょう。

そのためのツールを用意しました: [migrate2rocky](https://github.com/rocky-linux/rocky-tools/tree/main/migrate2rocky).

このスクリプトを実行すると、サーバ内の全リポジトリがRocky Linuxのものに変更されます。必要に応じてパッケージがインストールされたり、アップグレード/ダウングレードされたりします。OSのブランディングもすべて変更されます。

あなたがシステム管理に慣れていなくても、できるだけわかりやすく説明しますのでご安心ください。まあ、コマンドラインと同じくらいですけどね。

### 警告と注意事項

1. migrate2rockyのREADMEページ(上記リンク)を確認してみてください。なぜなら、このスクリプトとKatelloのリポジトリの間には既知のコンフリクトや非互換性があるためです。また時間の経過とともに、より多くのコンフリクトや非互換性が発見される（最終的には修正される）可能性があります。
2. このスクリプトは、完全に新規にインストールした場合に問題なく動作する可能性が高いです。_実際の本番環境で使用する場合は、**あらかじめデータのバックアップとシステムのスナップショットを作成するか、まずステージング環境で実行してください。**_

準備はいいですか？ さあ、始めましょう。

## サーバーの準備

まずリポジトリから実際のスクリプトファイルを取得する必要があります。これにはいくつかの方法があります。


### 手動で行う方法

GitHub からzipファイルをダウンロードし、必要なものを解凍します (例：migrate2rocky.sh)。zipファイルはGitHub リポジトリのトップページの右端にあります。:

![The "Download Zip" button](images/migrate2rocky-github-zip.png)

次に、ローカルマシンで以下のコマンドを実行して、実行ファイルをscpでサーバにアップロードします。:

```
scp PATH/TO/FILE/migrate2rocky.sh root@yourdomain.com:/home/
```

必要に応じて、ファイルのパスや、サーバのドメインやIPアドレスを調整してください。

### gitで行う方法

サーバーにgitをインストールします。:

```
dnf install git
```

次に、rocky-toolsのリポジトリをクローンします。:

```
git clone https://github.com/rocky-linux/rocky-tools.git
```

注意：この方法では、rocky-tools リポジトリ内のすべてのスクリプトとファイルがダウンロードされます。

### 簡単だけど、少しだけ安全ではない方法

さて、これはセキュリティ的には必ずしもベストな方法ではありません。しかし、スクリプトを入手するには最も簡単な方法です。

以下のコマンドを実行して、使用しているディレクトリにスクリプトをダウンロードします。:

```
curl https://raw.githubusercontent.com/rocky-linux/rocky-tools/main/migrate2rocky/migrate2rocky.sh -o migrate2rocky.sh
```

このコマンドを実行すると、サーバに必要とするファイルのみを直接ダウンロードします。ただし、セキュリティ上の問題があるため、必ずしもベストな方法ではありませんので、ご了承ください。

## スクリプトの実行とインストール


`cd`コマンドを使って、スクリプトのあるディレクトリに切り替え、ファイルが実行可能であることを確認し、スクリプトファイルのオーナーにx権限を与えます。:

```
chmod u+x migrate2rocky.sh
```

そして、いよいよ、スクリプトを実行します。:

```
./migrate2rocky.sh -r
```


この"-r "オプションは、すべてをインストールすることを意味します。

すべてが正しく行われると、ターミナルウィンドウは次のようになっているはずです。:


![a successful script startup](images/migrate2rocky-convert-01.png)

さて、スクリプトがすべてを変換するには、実際のマシンやサーバ、そしてインターネットへの接続状況に応じて、しばらく時間がかかります。

最後に **Complete!** のメッセージが表示されたら、スクリプトが問題なく行われたこと意味するためサーバを再起動することができます。

![a successful OS migration message](images/migrate2rocky-convert-02.png)

再起動してしばらくしてからログインしてみると、新しいRocky Linuxサーバで遊べるようになっています。
`hostnamectl`を入力して、OSが正しく移行されたかどうかを確認すれば、もう大丈夫です。

![The results of the hostnamectl command](images/migrate2rocky-convert-03.png)
