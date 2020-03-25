//
//  ViewController.swift
//  FTP
//
//  Created by Mac on 2020/03/25.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var FTPuploadButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.addSubview(FTPuploadButton)
    }
    
    //ボタンを押したとき
    @IBAction func FTPuploadButtonPush(_ sender: Any) {
        self.ftpupload()
    }
    
    //ftpアップロード
    func ftpupload()
    {
        let testList = ["test1","test2"]

        do {
            // ファイルに書き込み
            let jsonTextFileName = "test.txt"
            let jsonData = try JSONSerialization.data(withJSONObject: testList, options: [])
            let jsonStr = String(bytes: jsonData, encoding: .utf8)!
            self.writeFile(file_name: jsonTextFileName,text: jsonStr)
            
            if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first
             {
                 //urlをpathに変換
                 let pathURL = dir.appendingPathComponent( jsonTextFileName )
                 let pathString:String = pathURL.path
                 //FTPファイルアップロード
                 let ftpFunctions = FtpCreateClass()
                 ftpFunctions.createFile(pathName: pathString)
             }
        } catch let error {
            print(error)
        }
    }
    
    func writeFile(file_name: String,text: String)
    {
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first
        {
            let path_file_name = dir.appendingPathComponent( file_name )

            do {
                try text.write( to: path_file_name, atomically: false, encoding: String.Encoding.utf8 )
            } catch {
                //エラー処理
            }
        }
    }
}

class FtpCreateClass: BRRequestDelete {

    // 2. FTPアップロードオブジェクト
    var ftpUpload: BRRequestUpload!
    
    /// FTPアップロードデータ(空データ)
    var ftpUploadData: Data?

    /**
     FTPでファイル一覧の取得を開始します。
     */
    func createFile(pathName: String) {
        if ftpUpload != nil {
            // FTPアップロードオブジェクトが有効な場合、2重起動防止のため処理を終了します。
            return
        }

        // 3. FTPアップロードオブジェクトを生成し、FTPで接続するパラメータを設定します。
        ftpUpload = BRRequestUpload(delegate: self)
        ftpUpload.hostname = "192.168.1.2"
        ftpUpload.username = "testUser"
        ftpUpload.password = "testPassword"
        ftpUpload.path = pathName
        
        // 4. ファイル作成を開始します。
        ftpUpload.start()
    }
    
    /**
     5. FTPのリクエストが完了した時に呼び出されます。

     - Parameter request: FTPリクエスト
     */
    func requestCompleted(_ request: BRRequest) {
        if request == ftpUpload {
            // FTPリクエストがFTPアップロードオブジェクトと等しい場合
            // 正常終了の場合の処理を記述してください。
            
            // 6. 2重起動防止のため、FTPアップロードオブジェクトをクリアします。
            ftpUpload = nil
        }
    }
    
    /**
     5. FTPリクエストがエラーした時に呼び出されれます。

     - Parameter request: FTPリクエスト
     */
    func requestFailed(_ request: BRRequest) {
        if request == ftpUpload {
            // FTPリクエストがFTPアップロードオブジェクトと等しい場合
            // エラー終了の場合の処理を記述してください。
            
            // 6. 2重起動防止のため、FTPアップロードオブジェクトをクリアします。
            ftpUpload = nil
        }
    }

    /**
     5. 上書きリクエスト時に呼び出されます。

     - Parameter request: FTPリクエスト
     */
    func shouldOverwriteFileWithRequest(_ request: BRRequest) -> Bool {
        if request == ftpUpload {
            // FTPリクエストがFTPアップロードオブジェクトと等しい場合
            // 上書きを許可します。
            return true

        } else {
            // 上記以外、上書きを禁止します。
            return false
        }
    }
    
    /**
     5. アップロードデータを送信します。

     - Parameter request: リクエスト
     - Returns: アップロードデータ
     */
    func requestData(toSend request: BRRequestUpload) -> Data {
        if let ftpUploadData = ftpUploadData {
            // FTPアップロードデータが有効な場合
            self.ftpUploadData = nil
            return ftpUploadData

        } else {
            return Data()
        }
    }
}
