//
//  MidAppSurveyTask.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 1/31/22.
//

import UIKit
import ResearchKit

public class SurveyHelper {
    public var MidAppSurveyTask: ORKOrderedTask {
        
        let anxiousAnswerChoices: [ORKTextChoice] = [
                                                     ORKTextChoice(text: "Not at all anxious", value: "Not at all anxious" as NSString),
                                                     ORKTextChoice(text: "Not very anxious", value: "Not very anxious" as NSString),
                                                     ORKTextChoice(text: "Neutral", value: "Neutral" as NSString),
                                                     ORKTextChoice(text: "Somewhat anxious", value: "Somewhat anxious" as NSString),
                                                     ORKTextChoice(text: "Very anxious", value: "Very anxious" as NSString)]
        let findAnswerChoices: [ORKTextChoice] = [
                                                 ORKTextChoice(text: "Not at all difficult", value: "Not at all difficult" as NSString),
                                                  ORKTextChoice(text: "Not very difficult", value: "Not very difficult" as NSString),
                                                  ORKTextChoice(text: "Neutral", value: "Neutral" as NSString),
                                                  ORKTextChoice(text: "Somewhat difficult", value: "Somewhat difficult" as NSString),
                                                  ORKTextChoice(text: "Very difficult", value: "Very difficult" as NSString)
                                                ]
        let moodQuestion = ORKQuestionStep(identifier: "moodStep",
                                                     title: "Question 1/4",
                                                     question: "Please rate your current mood from 0 to 10, where 0 represents your \"worst mood\" and 10 represents your \"best mood\"",
                                                     answer: ORKScaleAnswerFormat(maximumValue: 10, minimumValue: 0, defaultValue: 5, step: 1))
        let anxiousQuestion = ORKQuestionStep(identifier: "anxiousStep",
                                              title: "Question 2/4",
                                              question: "How anxious were you finding your way to this destination",
                                              answer: ORKValuePickerAnswerFormat(textChoices: anxiousAnswerChoices))
        let findingQuestion = ORKQuestionStep(identifier: "findQuestion",
                                              title: "Question 3/4",
                                              question: "How difficult was it to find this destination?",
                                              answer: ORKValuePickerAnswerFormat(textChoices: findAnswerChoices))
        let lostQuestion = ORKQuestionStep(identifier: "orientationStep",
                                              title: "Question 4/4",
                                              question: "Did you feel you were lost at any moment?",
                                              answer: ORKBooleanAnswerFormat())
        
        let completeStep = ORKCompletionStep(identifier: "CompletionStep")
        completeStep.title = "Complete!"
        completeStep.text = "Please head to the next destination!"
        
        moodQuestion.isOptional = false
        anxiousQuestion.isOptional = false
        findingQuestion.isOptional = false
        lostQuestion.isOptional = false
        
        return ORKOrderedTask(identifier: "SurveyTask", steps: [
            moodQuestion,
            anxiousQuestion,
            findingQuestion,
            lostQuestion,
            completeStep])
    }

    public func storeSurveyResultsLocally(taskViewController: ORKTaskViewController, reason: ORKTaskViewControllerFinishReason) {
        switch(reason) {
        case .completed:
            fallthrough
        case .saved:
            taskViewController.result.results?.forEach({ ORKResult in
                let stepResult = ORKResult as! ORKStepResult
                stepResult.results?.forEach({ subAnswer in
                    switch subAnswer {
                    case is ORKScaleQuestionResult:
                        UserData.surveyResults.append((subAnswer as! ORKScaleQuestionResult).scaleAnswer!.stringValue as NSString)
                        break
                    case is ORKChoiceQuestionResult:
                        let choiceResult = (subAnswer as! ORKChoiceQuestionResult).choiceAnswers?.first
                        UserData.surveyResults.append(choiceResult as! NSString)
                        break
                    default:
                        let booleanResult = (subAnswer as! ORKBooleanQuestionResult).booleanAnswer
                        let convertedAnswer = booleanResult!.stringValue == "0" ? "No" : "Yes"
                        UserData.surveyResults.append(convertedAnswer as NSString)
                        break
                    }
                })
            })
            break
        default:
            break
        }
    }
}
