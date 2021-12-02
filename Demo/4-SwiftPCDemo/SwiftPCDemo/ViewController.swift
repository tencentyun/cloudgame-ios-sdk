//
//  ViewController.swift
//  SwiftPCDemo
//
//  Created by LyleYu on 2021/10/27.
//

import UIKit

class ViewController: UIViewController {
    
    var gamePlayer : TCGGamePlayer?
    var gameController : TCGGameController?
    var mouseCursor : TCGVirtualMouseCursor?
    var userId : String?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.gray
        let startBtn = UIButton(type: .custom)
        startBtn.frame = CGRect(x:50, y:50, width:100, height:45)
        startBtn.setTitle(_:"Start", for: .normal)
        startBtn.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        self.view.addSubview(startBtn)

        let stopBtn = UIButton(type: .custom)
        stopBtn.frame = CGRect(x:150, y:50, width:100, height:45)
        stopBtn.setTitle(_:"Stop", for: .normal)
        stopBtn.addTarget(self, action: #selector(stopGame), for: .touchUpInside)
        self.view.addSubview(stopBtn)
        
        userId =  String(format: "SwiftPCDemo-%@", UUID().uuidString)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopGame()
    }

    @objc func startGame() -> Void {
        print("startGame")
        self.createGamePlayer()
    }
    
    func doStartGame(_ remoteSession:String) {
        print("从业务后台成功申请到云端机器")
        DispatchQueue.main.async {
            try? self.gamePlayer?.startGame(withRemoteSession: remoteSession)
        }
    }

    @objc func stopGame() {
        DispatchQueue.main.async {
            if let v = self.mouseCursor {
                v.removeFromSuperview()
                self.mouseCursor = nil
            }
            if let v = self.gamePlayer?.videoView() {
                v.removeFromSuperview()
            }
            if let player = self.gamePlayer {
                player.stopGame()
                self.gamePlayer = nil
            }
            if let uid = self.userId {
                let releaseSession = "https://service-dn0r2sec-1304469412.gz.apigw.tencentcs.com/release/StopCloudGame"
                self.postUrl(releaseSession, ["UserId":uid]) { (data:Data?, req:URLResponse?, err:Error?) in
                    if err != nil || data == nil {
                        print("释放机器失败:\(err.debugDescription)")
                    }
                    print("已释放云端机器")
                }
            }

        }
        
    }
    
    func createGamePlayer() {
        if gamePlayer != nil {
            return
        }
        gamePlayer = TCGGamePlayer.init(params: ["local_audio":0], andDelegate: self)
        gamePlayer?.setConnectTimeout(10)
        gamePlayer?.setStreamBitrateMix(1000, max: 3000, fps: 45)
        gameController = gamePlayer?.gameController
        gameController?.controlDelegate = self;
        
        gamePlayer?.videoView().frame = self.view.bounds
        
        mouseCursor = TCGVirtualMouseCursor.init(frame: self.view.bounds, controller: gameController)
        // 设置默认的鼠标指针图片，防止后台未及时下放时显示空白
        mouseCursor?.setCursorImage(#imageLiteral(resourceName: "default_cursor"), andRemoteFrame: CGRect(x:0, y:0, width:32, height:32))
        if let cursor = mouseCursor {
            gamePlayer?.videoView().addSubview(cursor)
        }
        if let v = gamePlayer?.videoView() {
            self.view.insertSubview(v, at: 0)
        }
    }
    
    func getRemoteSession(_ localSession:String) -> Void {
        let createSession = "https://service-dn0r2sec-1304469412.gz.apigw.tencentcs.com/release/StartCloudGame"
        if let uid = self.userId {
            self.postUrl(createSession, ["GameId":"game-nf771d1e", "UserId":uid, "ClientSession":localSession]) { (data:Data?, req:URLResponse?, err:Error?) in
                if err != nil {
                    print("申请云端机器失败:\(err.debugDescription)")
                    return
                }
                if let data = data {
                    guard let infoDic = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary else {
                        return }
                    guard let valueDic = infoDic["data"] as? [String : AnyObject] else {
                        print("返回结果异常:\(infoDic)")
                        return }
                    guard let session = valueDic["ServerSession"] as? String else {
                        print("返回结果异常:\(infoDic)")
                        return }
                    self .doStartGame(session)
                } else {
                    print("返回结果异常:")
                }
            }
        }
    }

    func postUrl(_ urlStr:String, _ params:Dictionary<String, String>, _ blk:@escaping (Data?, URLResponse?, Error?) -> Void) {
        let session = URLSession.shared
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let task = session.uploadTask(with: request, from: jsonData, completionHandler:blk)
        task.resume()
    }
}

extension ViewController : TCGGamePlayerDelegate {
    func onInitSuccess(_ localSession: String!) {
        print("onInitSuccess 本地初始化成功")
        self.getRemoteSession(localSession)
    }
    
    func onInitFailure(_ errorCode: TCGErrorType, msg errorMsg: Error!) {
        print("onInitFailure \(errorCode) \(errorMsg.debugDescription)")
        self.stopGame()
    }
    
    func onConnectionFailure(_ errorCode: TCGErrorType, msg errorMsg: Error!) {
        print("onConnectionFailure \(errorCode) \(errorMsg.debugDescription)")
        self.stopGame()
    }
    
    func onStartReConnect(withReason reason: TCGErrorType) {
        print("onStartReConnect \(reason) 与云端链接断开，SDK内部重连中")
    }
    
    func onVideoSizeChanged(_ videoSize: CGSize) {
        print("onVideoSizeChanged 更新画面尺寸: \(videoSize.debugDescription)")
        var newWidth = self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right
        var newHeight = self.view.frame.size.height
        // 游戏画面强制横屏、设置游戏画面居中显示类似 UIViewContentModeScaleAspectFit
        if newWidth/newHeight < videoSize.width/videoSize.height {
            newHeight = floor(newWidth * videoSize.height / videoSize.width)
        } else {
            newWidth = floor(newHeight * videoSize.width / videoSize.height)
        }
        if let v = self.gamePlayer?.videoView() {
            v.frame = CGRect(x:(self.view.frame.size.width - newWidth) / 2,
                             y:(self.view.frame.size.height - newHeight) / 2,
                             width: newWidth, height: newHeight)
            if let mouse = self.mouseCursor {
                mouse.frame = v.bounds
            }
        }
    }
    
    func onVideoOrientationChanged(_ orientation: UIInterfaceOrientation) {
        print("onVideoOrientationChanged \(orientation)")
    }
    
    func onVideoShow() {
        print("onVideoShow, 游戏开始有画面")
        // 设置正确的鼠标显示与控制模式
        self.gameController?.setCursorShowMode(TCGMouseCursorShowMode.local)
        self.mouseCursor?.setCursorTouchMode(TCGMouseCursorTouchMode.relativeTouch)
    }
    
}

extension ViewController : TCGGameControllerDelegate {
    func onCursorImageUpdated(_ image : UIImage, frame imageFrame : CGRect) {
        self.mouseCursor?.setCursorImage(image, andRemoteFrame: imageFrame)
    }
    
    func onCursorVisibleChanged(_ isVisble:Bool) {
        print("onCursorVisibleChanged 鼠标状态:\(isVisble)");
        self.mouseCursor?.setCursorIsShow(isVisble)
    }
}
