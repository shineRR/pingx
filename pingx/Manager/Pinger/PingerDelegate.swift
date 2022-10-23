//
// PingerDelegate.swift
// pingx
//
// Created by Ilya Baryko on 23.10.22.
// 
//

import Foundation

public protocol PingerDelegate: AnyObject {
    func pinger(_ pinger: PingerInterface, request: Request, didReceive: Response)
    func pinger(_ pinger: PingerInterface, request: Request, didCompleteWithError: Error)
}
