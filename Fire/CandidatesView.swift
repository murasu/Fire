//
//  FireCandidatesView.swift
//  Fire
//
//  Created by 虚幻 on 2019/9/16.
//  Copyright © 2019 qwertyyb. All rights reserved.
// 

import SwiftUI
import Defaults

func getShownCode(candidate: Candidate, origin: String) -> String {
    if candidate.type == CandidateType.py || !candidate.code.hasPrefix(origin) {
        return "(\(candidate.code))"
    }
    if candidate.code.hasPrefix(origin) {
        return candidate.code.count > origin.count
            ? "~\(String(candidate.code.suffix(candidate.code.count - origin.count)))"
            : ""
    }
    return ""
}

struct CandidateView: View {
    var candidate: Candidate
    var index: Int
    var origin: String
    var selected: Bool = false

    @Default(.themeConfig) private var themeConfig
    @Default(.wubiCodeTip) private var wubiCodeTip
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let indexColor = selected
            ? themeConfig[colorScheme].selectedIndexColor
            : themeConfig[colorScheme].candidateIndexColor
        let textColor = selected
            ? themeConfig[colorScheme].selectedTextColor
            : themeConfig[colorScheme].candidateTextColor
        let codeColor = selected
            ? themeConfig[colorScheme].selectedCodeColor
            : themeConfig[colorScheme].candidateCodeColor

        return HStack(alignment: .center, spacing: 2) {
            Text("\(index + 1).")
                .foregroundColor(Color(indexColor))
            VStack {
                Text(candidate.text)
                    .foregroundColor(Color(textColor))
                Text("Annotation")
                    .foregroundColor(.gray)
                    .f
            }
            if wubiCodeTip {
                Text(getShownCode(candidate: candidate, origin: origin))
                    .foregroundColor(Color(codeColor))
            }
        }
        .onTapGesture {
            NotificationCenter.default.post(
                name: Fire.candidateSelected,
                object: nil,
                userInfo: [
                    "candidate": candidate,
                    "index": index
                ]
            )
        }
    }
}

struct CandidatesView: View {
    var candidates: [Candidate]
    var origin: String
    var hasPrev: Bool = false
    var hasNext: Bool = false

    @Default(.candidatesDirection) private var direction
    @Default(.themeConfig) private var themeConfig
    @Default(.showCodeInWindow) private var showCodeInWindow
    @Environment(\.colorScheme) var colorScheme

    var _candidatesView: some View {
        ForEach(Array(candidates.enumerated()), id: \.element) { (index, candidate) -> CandidateView in
            CandidateView(
                candidate: candidate,
                index: index,
                origin: origin,
                selected: index == 0
            )
        }
    }

    func getIndicatorIcon(imageName: String, direction: CandidatesDirection, disabled: Bool, eventName: Notification.Name) -> some View {
        return Image(imageName)
            .renderingMode(.template)
            .resizable()
            .frame(width: 10, height: 10, alignment: .center)
            .rotationEffect(Angle(degrees: direction == CandidatesDirection.horizontal ? 0 : -90), anchor: .center)
            .onTapGesture {
                if disabled { return }
                NotificationCenter.default.post(
                    name: eventName,
                    object: nil
                )
            }
            .foregroundColor(Color(disabled
                                   ? themeConfig[colorScheme].pageIndicatorDisabledColor
                                   : themeConfig[colorScheme].pageIndicatorColor
                                  ))
    }

    var _indicator: some View {
        let arrowUp = getIndicatorIcon(
            imageName: "arrowUp",
            direction: direction,
            disabled: !hasPrev,
            eventName: Fire.prevPageBtnTapped
        )
        let arrowDown = getIndicatorIcon(
            imageName: "arrowDown",
            direction: direction,
            disabled: !hasNext,
            eventName: Fire.nextPageBtnTapped
        )
        if direction == CandidatesDirection.horizontal {
            return AnyView(VStack(spacing: 0) { arrowUp; arrowDown })
        } else {
            return AnyView(HStack(spacing: 4) { arrowUp; arrowDown })
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat( themeConfig[colorScheme].originCandidatesSpace), content: {
            if showCodeInWindow {
                Text(origin)
                    .foregroundColor(Color(themeConfig[colorScheme].originCodeColor))
                    .fixedSize()
            }
            if direction == CandidatesDirection.horizontal {
                HStack(alignment: .center, spacing: CGFloat(themeConfig[colorScheme].candidateSpace)) {
                    _candidatesView
                    _indicator
                }
                .fixedSize()
            } else {
                VStack(alignment: .leading, spacing: CGFloat(themeConfig[colorScheme].candidateSpace)) {
                    _candidatesView
                    _indicator
                }
                .fixedSize()
            }
        })
            .padding(.top, CGFloat(themeConfig[colorScheme].windowPaddingTop))
            .padding(.bottom, CGFloat(themeConfig[colorScheme].windowPaddingBottom))
            .padding(.leading, CGFloat(themeConfig[colorScheme].windowPaddingLeft))
            .padding(.trailing, CGFloat(themeConfig[colorScheme].windowPaddingRight))
            .fixedSize()
            .font(.system(size: CGFloat(themeConfig[colorScheme].fontSize)))
            .background(Color(themeConfig[colorScheme].windowBackgroundColor))
            .cornerRadius(CGFloat(themeConfig[colorScheme].windowBorderRadius), antialiased: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CandidatesView(candidates: [
            Candidate(code: "a", text: "工", type: CandidateType.wb),
            Candidate(code: "ab", text: "戈", type:  CandidateType.wb),
            Candidate(code: "abc", text: "啊", type:  CandidateType.wb),
            Candidate(code: "abcg", text: "阿", type:  CandidateType.wb),
            Candidate(code: "addd", text: "吖", type:  CandidateType.wb)
        ], origin: "a")
    }
}
