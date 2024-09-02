//
//  CloudTextModel.swift
//  Queryable
//
//  Created by Dy Wang on 2024/9/2.
//

import Foundation
import CoreML

class CloudTextModel {
    static let shared = CloudTextModel()

    private var encodedLabels: [MLShapedArray<Float32>] = []
    private var cloud_encodeds_encoded: [MLShapedArray<Float32>] = []
    
    private init() {
        let textEncoder = try! TextEncoder()
        
        for label in cloud_labels_0 {
            let embedding = try! textEncoder.computeTextEmbedding(prompt: label)
            self.encodedLabels.append(embedding)
        }
        

        for cloud_encoded in cloud_encodeds {
            let embedding = try! textEncoder.computeTextEmbedding(prompt: cloud_encoded)
            cloud_encodeds_encoded.append(embedding)
        }
    }

    private let cloud_encodeds = [
        "cloud",
        "clouds",
        "sky"
    ]

    func hasCloud(in embedding: MLShapedArray<Float32>) async -> Bool {
        for cloudEmbedding in cloud_encodeds_encoded {
            let similarity = await CLIPHelper.shared.cosine_similarity(A: embedding, B: cloudEmbedding)
            print("================ similarity: \(similarity)")
            if similarity > 0.2 { // 设定一个相似度阈值
                return true
            }
        }
        return false
    }

    private let cloud_labels_0 = [
        // 1: 卷云
        "Cirrus clouds are short, detached, hair-like clouds found at high altitudes. These delicate clouds are wispy, with a silky sheen, or look like tufts of hair. In the daytime, they are whiter than any other cloud in the sky. While the Sun is setting or rising, they may take on the colours of the sunset.",
        // 常呈现丝条状、羽毛状、马尾状、钩状、片状或砧状等

        // 2: 卷积云
        "Cirrocumulus clouds are made up of lots of small white clouds called cloudlets, which are usually grouped together at high levels. Composed almost entirely from ice crystals, the little cloudlets are regularly spaced, often arranged as ripples in the sky.",
        // 似鳞片或球状细小云块。

        // 3: 卷层云
        "Cirrostratus are transparent high clouds, which cover large areas of the sky. They sometimes produce white or coloured rings, spots or arcs of light around the Sun or Moon, that are known as halo phenomena. Sometimes they are so thin that the halo is the only indication that a cirrostratus cloud is in the sky.",
        // 呈现薄幕状。

        // 4: 高积云
        "Altocumulus clouds are small mid-level layers or patches of clouds, called cloudlets, which most commonly exist in the shape of rounded clumps. There are many varieties of altocumulus, however, meaning they can appear in a range of shapes. Altocumulus are made up of a mix of ice and water, giving them a slightly more ethereal appearance than the big and fluffy lower level cumulus.",
        // 呈扁圆形、瓦片状等，且以波浪形排列。

        // 5: 高层云
        "Altostratus are large mid-level sheets of thin cloud. Usually composed of a mixture of water droplets and ice crystals, they are thin enough in parts to allow you to see the Sun weakly through the cloud. They are often spread over a very large area and are typically featureless.",
        // 像一种带有条纹的幕，颜色多为灰白色或灰色。

        // 6: 雨层云
        // "Nimbostratus clouds are dark, grey, featureless layers of cloud, thick enough to block out the Sun. Producing persistent rain, these clouds are often associated with frontal systems provided by mid-latitude cyclones. These are probably the least picturesque of all the main cloud types."


        // 7: 层积云
        "Stratocumulus clouds are low-level clumps or patches of cloud varying in colour from bright white to dark grey. They are the most common clouds on earth recognised by their well-defined bases, with some parts often darker than others. They usually have gaps between them, but they can also be joined together.",

        // 8: 层云
        "Stratus clouds are low-level layers with a fairly uniform grey or white colour. Often the scene of dull, overcast days in its 'nebulosus' form, they can persist for long periods of time. They are the lowest-lying cloud type and sometimes appear at the surface in the form of mist or fog.",


        // 9: 积云
        "Cumulus clouds are detached, individual, cauliflower-shaped clouds usually spotted in fair weather conditions. The tops of these clouds are mostly brilliant white tufts when lit by the Sun, although their base is usually relatively dark.",

        // 10: 积雨云
    ]    

    private let cloud_labels_0_name = [
        "卷云",
        "卷积云",
        "卷层云",
        "高积云",
        "高层云",
        //"雨层云",
        "层积云",
        "层云",
        "积云",
        //"积雨云"
    ]

    func findClosestCloudLabel(for encodedImage: MLShapedArray<Float32>) async -> String? {

        var value:Float = -1.0
        var resultIndex = 0
        for (index, encodedLabel) in encodedLabels.enumerated() {
            let distance = await CLIPHelper.shared.cosine_similarity(A: encodedImage, B: encodedLabel)
            print("================ distance: \(distance)")
            if distance > value {
                value = distance
                resultIndex = index
            }
        }
        
        return cloud_labels_0_name[resultIndex]
    }
}
