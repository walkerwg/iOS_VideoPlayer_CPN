import UIKit
import XCTest
import JHKVideoPlayer

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // 测试 - 1 - 测试根据frame生成播放器控件 - 期望结果生成成功
    func testVideoPlayerInitializeFromFrame() {
        
        let playerView = JHKVideoPlayer(frame:CGRect(x:10, y:40, width:300, height:180))
        
        XCTAssertNotNil(playerView)
    }
    
    // 测试 - 2 - 测试根据URL生成播放器控件 - 期望结果生成成功
    func testVideoPlayerInitializeFromURL() {
        
        let playerView = JHKVideoPlayer(url: "http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4")
        
        XCTAssertNotNil(playerView)
    }
    
    // 测试 - 3 - 测试设置播放器是否自动开始播放 - 期望播放状态与信号布尔值一致
    func testVideoPlayerImplementFromURL() {
        
        let playerView = JHKVideoPlayer(url: "http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4")
        playerView.autoStart = true
        self.waitForExpectations(timeout: 15) {
            error in
            if let error = error {
                XCTFail("等待超时 \(error.localizedDescription)")
            }
        }
        XCTAssertEqual(playerView.playState, .playing)
        
        let playerView2 = JHKVideoPlayer(url: "http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4")
        playerView2.autoStart = false
        self.waitForExpectations(timeout: 15) {
            error in
            if let error = error {
                XCTFail("等待超时 \(error.localizedDescription)")
            }
        }
        XCTAssertEqual(playerView2.playState, .stop)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
