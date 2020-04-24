//
//  CropImageService.swift
//  Runner
//
//  Created by Masanao Imai on 2020/04/24.
//

import Foundation

final class CropImageService {
    static let shared = CropImageService()
    private var permissionChannel: FlutterMethodChannel?
    
    private init() {}
    
    func configureFlutterHandler(flutterBinaryMessenger: FlutterBinaryMessenger) {
        permissionChannel = FlutterMethodChannel(name: "photo.sample.app/crop.image", binaryMessenger: flutterBinaryMessenger)
        permissionChannel?.setMethodCallHandler { [weak self] (call, result) in
            // https://api.flutter.dev/flutter/services/MethodChannel/invokeMethod.html
            switch (call.method) {
            case "getImageProperties":
                self?.getImageProperties(call, result: result)
                break;
            case "cropImage":
                self?.cropImage(call, result: result)
                break;
            default:
                print("error method is not match!!")
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func getImageProperties(_ call: FlutterMethodCall, result: FlutterResult) {
        if let args = call.arguments as? Dictionary<String, Any>,
            let filePath = args["filePath"] as? String {
            let imageProperties: Dictionary = ImagePlugin.getImageProperties(filePath)
            print(imageProperties)
            result(imageProperties)
        } else {
            result(FlutterError.init(code: "bad args", message: nil, details: nil))
        }
    }
    
    private func cropImage(_ call: FlutterMethodCall, result: FlutterResult) {
        if let args = call.arguments as? Dictionary<String, Any>,
            let filePath = args["filePath"] as? String,
            let originX = args["originX"] as? Int32,
            let originY = args["originY"] as? Int32,
            let width = args["width"] as? Int32,
            let height = args["height"] as? Int32
        {
            let croppedImagePath: String = ImagePlugin.cropImage(filePath, originX: originX, originY: originY, width: width, height: height);
            print(croppedImagePath)
            result(croppedImagePath)
        } else {
            result(FlutterError.init(code: "bad args", message: nil, details: nil))
        }
    }
}
