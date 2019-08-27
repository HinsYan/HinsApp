//
//  BTNFilterManager.swift
//  BetterNet
//
//  Created by yantommy on 2016/12/31.
//  Copyright © 2016年 yantommy. All rights reserved.
//

import UIKit
import GPUImage

enum BTNFilterCategory: Int {
    
    case normal = 0
    case beautyFace
    case distinct
    case lightDark
    case pixellate
    case sketch
    case toon
}


//
//groupFilter.addFilter(bilateralFilter)
//groupFilter.addFilter(brightnessfilter)
//
//let stretchDistortionFilter = GPUImageStretchDistortionFilter()
//groupFilter.addFilter(stretchDistortionFilter)
//
//bilateralFilter.addTarget(stretchDistortionFilter)
//stretchDistortionFilter.addTarget(brightnessfilter)
//groupFilter.initialFilters = [bilateralFilter]


// MARK: -先加滤镜 再输出到view
//videoCamera.addTarget(bilateralFilter)
//bilateralFilter.addTarget(filterView)
//没有加滤镜的时候记住要对相机加输出View
//videoCamera.addTarget(filterView)

// MARK: -GPUImageFilterGroup原理：
//1. filterGroup(addFilter) 滤镜组添加每个滤镜
//2. 按添加顺序（可自行调整）前一个filter(addTarget) 添加后一个filter
//3. filterGroup.initialFilters = [第一个filter]]
//4. filterGroup.terminalFilter = 最后一个filter



public class HinsFilterManager: NSObject {
    
    
    static var currentFilter: GPUImageFilterGroup! = {
        HinsFilterManager.allFilters.first!
    }()
    
    static var allFilters: [GPUImageFilterGroup]! = {
        
        var filter1: GPUImageFilterGroup = {
            let filterGroup = GPUImageFilterGroup()
            
            let filter1 = GPUImageBrightnessFilter()
            let filter2 = GPUImageBilateralFilter()
            
            filter1.brightness = 0.2
            filter2.distanceNormalizationFactor = 10.0
            
            filterGroup.addFilter(filter1)
            filterGroup.addFilter(filter2)
            
            filter1.addTarget(filter2)
            
            filterGroup.initialFilters = [filter1]
            filterGroup.terminalFilter = filter2
            
            return filterGroup
        }()
        
        var filter2: GPUImageFilterGroup = {
            let filterGroup = GPUImageFilterGroup()
            
            //
            let filter1 = GPUImageSepiaFilter()
            
            //亮度（-1 0 1）
            let filter2 = GPUImageBrightnessFilter()
            filter2.brightness = 0.1
            
            filterGroup.addFilter(filter1)
            filterGroup.addFilter(filter2)
            
            filter1.addTarget(filter2)
            
            filterGroup.initialFilters = [filter1]
            filterGroup.terminalFilter = filter2
            
            return filterGroup
            
        }()
        
        var filter3: GPUImageFilterGroup = {
            let filterGroup = GPUImageFilterGroup()
            
            //锐化(-4 0 4)
            let filter1 = GPUImageThresholdSketchFilter()

            //亮度（-1 0 1）
            let filter2 = GPUImageBrightnessFilter()
            filter2.brightness = 0.1
            
            filterGroup.addFilter(filter1)
            filterGroup.addFilter(filter2)
            
            filter1.addTarget(filter2)
            
            filterGroup.initialFilters = [filter1]
            filterGroup.terminalFilter = filter2
            
            return filterGroup
        }()
        
        var filter4: GPUImageFilterGroup = {
            let filterGroup = GPUImageFilterGroup()
            
            //灰度()
            let filter1 = GPUImageGrayscaleFilter()
            
            //亮度（-1 0 1）
            let filter2 = GPUImageBrightnessFilter()
            filter2.brightness = 0
            
            filterGroup.addFilter(filter1)
            filterGroup.addFilter(filter2)
            
            filter1.addTarget(filter2)
            
            filterGroup.initialFilters = [filter1]
            filterGroup.terminalFilter = filter2
            
            
            return filterGroup
        }()
        
        var filter5: GPUImageFilterGroup = {
            let filterGroup = GPUImageFilterGroup()
            
            //彩色马赛克(像素大小)
            let filter1 = GPUImagePixellateFilter()
            
            //亮度（-1 0 1）
            let filter2 = GPUImageBrightnessFilter()
            filter2.brightness = 0
            
            filterGroup.addFilter(filter1)
            filterGroup.addFilter(filter2)
            
            filter1.addTarget(filter2)
            
            filterGroup.initialFilters = [filter1]
            filterGroup.terminalFilter = filter2
            
            
            return filterGroup
        }()
        
        var filter6: GPUImageFilterGroup = {
            let filterGroup = GPUImageFilterGroup()
            
            //彩色马赛克(像素大小)
            let filter1 = GPUImageSmoothToonFilter()
            filter1.threshold = 0.5
            filter1.blurRadiusInPixels = 15
            
            //亮度（-1 0 1）
            let filter2 = GPUImageBrightnessFilter()
            filter2.brightness = 0.0
            
            filterGroup.addFilter(filter1)
            filterGroup.addFilter(filter2)
            
            filter1.addTarget(filter2)
            
            filterGroup.initialFilters = [filter1]
            filterGroup.terminalFilter = filter2
            
            
            return filterGroup
        }()
        
        var filter7: GPUImageFilterGroup = {
            let filterGroup = GPUImageFilterGroup()
            
            //带点素描(0 - 1，默认0.8，低于它为白色，高于为黑色)
            let filter1 = GPUImageAverageLuminanceThresholdFilter()
            
            //亮度（-1 0 1）
            let filter2 = GPUImageFalseColorFilter()
            
            filterGroup.addFilter(filter1)
            filterGroup.addFilter(filter2)
            
            filter1.addTarget(filter2)
            
            filterGroup.initialFilters = [filter1]
            filterGroup.terminalFilter = filter2
            
            return filterGroup
        }()

        return [filter1,filter2,filter3,filter4,filter5,filter6,filter7]
        
    }()
    

    
}
