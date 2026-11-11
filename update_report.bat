@echo off
chcp 65001 >nul
setlocal

echo ===================================================
echo  競馬予測レポート更新 & GitHub プッシュ処理を開始します
echo ===================================================

set "SOURCE_FILE=C:\keiba\keiba_pipeline\reports\forward_performance_report.html"
set "TARGET_DIR=C:\keiba_report"
set "TARGET_FILE=%TARGET_DIR%\index.html"

:: 1. コピー元ファイルの存在確認
if not exist "%SOURCE_FILE%" (
    echo [ERROR] コピー元ファイルが見つかりません:
    echo "%SOURCE_FILE%"
    goto FAILED
)

:: 2. リポジトリフォルダへ移動
cd /d "%TARGET_DIR%"
if errorlevel 1 (
    echo [ERROR] ディレクトリの移動に失敗しました: %TARGET_DIR%
    goto FAILED
)

:: 3. ファイルを index.html として上書きコピー
echo.
echo [1/3] レポートファイルをコピー中...
copy /y "%SOURCE_FILE%" "%TARGET_FILE%" >nul
if errorlevel 1 (
    echo [ERROR] ファイルのコピーに失敗しました。
    goto FAILED
)
echo コピー完了: index.html

:: 4. 差分のステージング
echo.
echo [2/3] Git ステージングおよびコミット処理中...
git add index.html

:: 変更があるか確認してコミット
git diff --cached --quiet
if not errorlevel 1 (
    echo [INFO] 前回のファイルから変更がありませんでした。プッシュをスキップします。
    goto SUCCESS
)

:: 日時を取得してコミットメッセージに設定
set "TIMESTAMP=%DATE% %TIME:~0,8%"
git commit -m "Update report: %TIMESTAMP%"
if errorlevel 1 (
    echo [ERROR] git commit に失敗しました。
    goto FAILED
)

:: 5. GitHubへプッシュ
echo.
echo [3/3] GitHub (mainブランチ) へプッシュ中...
git push origin main
if errorlevel 1 (
    echo [ERROR] git push に失敗しました。ネットワーク接続や認証を確認してください。
    goto FAILED
)

:SUCCESS
echo.
echo ===================================================
echo  すべての処理が正常に完了しました！
echo  公開URL (1〜2分で自動反映):
echo  https://htdn-yuya.github.io/keiba-report-app/
echo ===================================================
goto END

:FAILED
echo.
echo ===================================================
echo  処理が中断されました。上記のエラーを確認してください。
echo ===================================================

:END
pause