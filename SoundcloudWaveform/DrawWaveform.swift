//
//  DrawWaveform.swift
//  SoundcloudWaveform
//
//  Created by Matthew S. Hill on 3/22/17.
//  Copyright © 2017 Matthew S. Hill. All rights reserved.
//

import Foundation
import UIKit
import Accelerate

class DrawWaveform: UIView {
    override func draw(_ rect: CGRect) {
       //downsample and convert
        self.convertToPoints()
        
        var f = 0
        let aPath = UIBezierPath()
        let aPath2 = UIBezierPath()
        
        aPath.lineWidth = 2.0
        aPath2.lineWidth = 2.0
        
        aPath.move(to: CGPoint(x:0.0, y:rect.height/2))
        aPath2.move(to: CGPoint(x:0.0, y:rect.height))
        
        for _ in readFile.points {
            var x:CGFloat = 2.5
            aPath.move(to: CGPoint(x:aPath.currentPoint.x + x,y:aPath.currentPoint.y))
            //amplitude
            aPath.addLine(to: CGPoint(x:aPath.currentPoint.x, y:aPath.currentPoint.y - (readFile.points[f] * 70) - 1.0))
            
            aPath.close()
            
            x += 1
            f += 1
        }
        
        UIColor.blue.set()
        aPath.stroke()
        aPath.fill()
        
        f = 0
        aPath2.move(to: CGPoint(x:0.0, y:rect.height/2))
        
        for _ in readFile.points {
            var x:CGFloat = 2.5
            aPath2.move(to: CGPoint(x:aPath2.currentPoint.x + x, y:aPath2.currentPoint.y))
            aPath2.addLine(to: CGPoint(x:aPath2.currentPoint.x, y:aPath2.currentPoint.y - (-1.0 * readFile.points[f] * 50)))
            aPath2.close()
            
            x += 1
            f += 1
        }
        
        UIColor.blue.set()
        aPath2.stroke(with: CGBlendMode.normal, alpha: 0.5)
        aPath2.fill()
    }
    
    //downsample the array of floats
    func convertToPoints() {
        var processingBuffer = [Float](repeating: 0.0, count: Int(readFile.arrayFloatValues.count))
        
        let sampleCount = vDSP_Length(readFile.arrayFloatValues.count)
        
        vDSP_vabs(readFile.arrayFloatValues, 1, &processingBuffer, 1, sampleCount)
        
        var multiplier = 1.0
        print(multiplier)
        if multiplier < 1 {
            multiplier = 1.0
        }
        
        let samplesPerPixel = Int(150 * multiplier)
        let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: Int(samplesPerPixel))
        let downSampledLength = Int(readFile.arrayFloatValues.count / samplesPerPixel)
        var downSampledData = [Float](repeating:0.0, count:downSampledLength)
        
        vDSP_desamp(processingBuffer, vDSP_Stride(samplesPerPixel), filter, &downSampledData, vDSP_Length(downSampledLength), vDSP_Length(samplesPerPixel))
        readFile.points = downSampledData.map{CGFloat($0)}
        
    }
}

struct readFile {
    static var arrayFloatValues:[Float] = []
    static var points:[CGFloat] = []
}
