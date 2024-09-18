//
//  CloudTextModel.swift
//  Queryable
//
//  Created by Dy Wang on 2024/9/2.
//

import Foundation
import CoreML

class CloudTextHelper {
    static let shared = CloudTextHelper()

    private var encodedLabels: [MLShapedArray<Float32>] = []
    private var cloud_encodeds_encoded: [MLShapedArray<Float32>] = []
    
    private init() {
        let textEncoder = try! TextEncoder()
        
        for label in cloud_labels_1 {
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
        "sky",
        "fog",
        "mist"
    ]

    func hasCloud(in embedding: MLShapedArray<Float32>) async -> Bool {
        for cloudEmbedding in cloud_encodeds_encoded {
            let similarity = await CLIPHelper.shared.cosine_similarity(A: embedding, B: cloudEmbedding)
            print("================ similarity: \(similarity)")
            if similarity >= 0.2 { // 设定一个相似度阈值
                return true
            }
        }
        return false
    }

    private let cloud_labels_1 = [
        // 1: 卷云
        "Cirrus clouds: Detached clouds in the form of white, delicate filaments or white or mostly white patches or narrow bands. These clouds have a fibrous (hair-like) appearance, or a silky sheen, or both.",

        // 2: 卷积云
        "Cirrocumulus clouds: Thin, white patch, sheet or layer of cloud without shading, composed of very small elements in the form of grains, ripples, etc., merged or separate, and more or less regularly arranged.",

        // 3: 卷层云
        "Cirrostratus clouds: Transparent, whitish cloud veil of fibrous (hair-like) or smooth appearance, totally or partly covering the sky, often producing halo phenomena. ",

        // 4: 高积云
        "Altocumulus clouds: Greyish or bluish cloud sheet or layer of striated, fibrous or uniform appearance, totally or partly covering the sky, and having parts thin enough to reveal the Sun at least vaguely, as through ground glass. Altostratus does not show halo phenomena.",

        // 5: 高层云
        "Altostratus clouds: Greyish or bluish cloud sheet or layer of striated, fibrous or uniform appearance, totally or partly covering the sky, and having parts thin enough to reveal the Sun at least vaguely, as through ground glass. Altostratus does not show halo phenomena.",
        // 像一种带有条纹的幕，颜色多为灰白色或灰色。

        // 6: 雨层云
        // "Nimbostratus clouds are dark, grey, featureless layers of cloud, thick enough to block out the Sun. Producing persistent rain, these clouds are often associated with frontal systems provided by mid-latitude cyclones. These are probably the least picturesque of all the main cloud types."


        // 7: 层积云
        "Stratocumulus clouds: Grey or whitish, or both grey and whitish, patch, sheet or layer of cloud that almost always has dark parts, composed of tessellations, rounded masses, rolls, etc., which are non-fibrous (except for virga) and which may or may not be merged; most of the regularly arranged small elements have an apparent width of more than 5°.",

        // 8: 层云
        //"Low-lying, uniform gray clouds that often cover the entire sky, bringing overcast conditions",
        "Stratus clouds: Generally grey cloud layer with a fairly uniform base, which may give drizzle, snow or snow grains. When the Sun is visible through the cloud, its outline is clearly discernible. Stratus does not produce halo phenomena except, possibly, at very low temperatures. Sometimes Stratus appears in the form of ragged patches.",


        // 9: 积云
        "Cumulus clouds: Detached clouds, generally dense and with sharp outlines, developing vertically in the form of rising mounds, domes or towers, of which the bulging upper part often resembles a cauliflower. The sunlit parts of these clouds are mostly brilliant white; their base is relatively dark and nearly horizontal.Sometimes, Cumulus is ragged.",

        // 10: 积雨云
    ]
    
    private let cloud_labels_0 = [
        // 1: 卷云
        "Cirrus clouds are short, detached, hair-like clouds. These delicate clouds are wispy, with a silky sheen, or look like tufts of hair. Detached clouds in the form of white, delicate filaments or white or mostly white patches or narrow bands. These clouds have a fibrous (hair-like) appearance, or a silky sheen, or both.",
        // 常呈现丝条状、羽毛状、马尾状、钩状、片状或砧状等

        // 2: 卷积云
        "Cirrocumulus clouds are made up of lots of small white clouds called cloudlets, which are usually grouped together at high levels. Composed almost entirely from ice crystals, the little cloudlets are regularly spaced, often arranged as ripples in the sky. Thin, white patch, sheet or layer of cloud without shading, composed of very small elements in the form of grains, ripples, etc., merged or separate, and more or less regularly arranged.",
        // 似鳞片或球状细小云块。

        // 3: 卷层云
        "Cirrostratus are transparent high clouds, which cover large areas of the sky. They sometimes produce white or coloured rings, spots or arcs of light around the Sun or Moon, that are known as halo phenomena. Sometimes they are so thin that the halo is the only indication that a cirrostratus cloud is in the sky. Transparent, whitish cloud veil of fibrous (hair-like) or smooth appearance, totally or partly covering the sky, often producing halo phenomena. ",
        // 呈现薄幕状。

        // 4: 高积云
        "Altocumulus clouds are small mid-level layers or patches of clouds, called cloudlets, which most commonly exist in the shape of rounded clumps. There are many varieties of altocumulus, however, meaning they can appear in a range of shapes. Altocumulus are made up of a mix of ice and water, giving them a slightly more ethereal appearance than the big and fluffy lower level cumulus. Greyish or bluish cloud sheet or layer of striated, fibrous or uniform appearance, totally or partly covering the sky, and having parts thin enough to reveal the Sun at least vaguely, as through ground glass. Altostratus does not show halo phenomena.",

        // 5: 高层云
        "Altostratus are large mid-level sheets of thin cloud. Usually composed of a mixture of water droplets and ice crystals, they are thin enough in parts to allow you to see the Sun weakly through the cloud. They are often spread over a very large area and are typically featureless. Greyish or bluish cloud sheet or layer of striated, fibrous or uniform appearance, totally or partly covering the sky, and having parts thin enough to reveal the Sun at least vaguely, as through ground glass. Altostratus does not show halo phenomena.",
        // 像一种带有条纹的幕，颜色多为灰白色或灰色。

        // 6: 雨层云
        // "Nimbostratus clouds are dark, grey, featureless layers of cloud, thick enough to block out the Sun. Producing persistent rain, these clouds are often associated with frontal systems provided by mid-latitude cyclones. These are probably the least picturesque of all the main cloud types."


        // 7: 层积云
        "Stratocumulus clouds are low-level clumps or patches of cloud varying in colour from bright white to dark grey. They are the most common clouds on earth recognised by their well-defined bases, with some parts often darker than others. They usually have gaps between them, but they can also be joined together. Grey or whitish, or both grey and whitish, patch, sheet or layer of cloud that almost always has dark parts, composed of tessellations, rounded masses, rolls, etc., which are non-fibrous (except for virga) and which may or may not be merged; most of the regularly arranged small elements have an apparent width of more than 5°.",

        // 8: 层云
        //"Low-lying, uniform gray clouds that often cover the entire sky, bringing overcast conditions",
        "Stratus clouds are low-level layers with a fairly uniform grey or white colour. Often the scene of dull, overcast days in its 'nebulosus' form, they can persist for long periods of time. They are the lowest-lying cloud type and sometimes appear at the surface in the form of mist or fog. Generally grey cloud layer with a fairly uniform base, which may give drizzle, snow or snow grains. When the Sun is visible through the cloud, its outline is clearly discernible. Stratus does not produce halo phenomena except, possibly, at very low temperatures. Sometimes Stratus appears in the form of ragged patches.",


        // 9: 积云
        "Cumulus clouds are detached, individual, cauliflower-shaped clouds usually spotted in fair weather conditions. The tops of these clouds are mostly brilliant white tufts when lit by the Sun, although their base is usually relatively dark. Detached clouds, generally dense and with sharp outlines, developing vertically in the form of rising mounds, domes or towers, of which the bulging upper part often resembles a cauliflower. The sunlit parts of these clouds are mostly brilliant white; their base is relatively dark and nearly horizontal.Sometimes, Cumulus is ragged.",

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
            print("\(cloud_labels_0_name[index]) ================ distance: \(distance)")
            if distance > value {
                value = distance
                resultIndex = index
            }
        }
        
        return cloud_labels_0_name[resultIndex]
    }
}
