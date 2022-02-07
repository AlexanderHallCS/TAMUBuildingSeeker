//
//  MidAppSurveyTask.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 1/31/22.
//

import UIKit
import ResearchKit

public var MidAppSurveyTask: ORKOrderedTask {
    let moodQuestion = ORKQuestionStep(identifier: "moodStep",
                                                 title: "Question 1/4",
                                                 question: "Please rate your current mood from 0 to 10, where 0 represents your \"worst mood\" and 10 represents your \"best mood\"",
                                                 answer: ORKScaleAnswerFormat(maximumValue: 10, minimumValue: 0, defaultValue: 5, step: 1))
    let multiAnswerChoices: [ORKTextChoice] = [ORKTextChoice(text: "Not at all anxious", value: 0 as NSNumber),ORKTextChoice(text: "Not very anxious", value: 1 as NSNumber),ORKTextChoice(text: "Neutral", value: 2 as NSNumber),ORKTextChoice(text: "Somewhat anxious", value: 3 as NSNumber),ORKTextChoice(text: "Very anxious", value: 4 as NSNumber)]
    let anxiousQuestion = ORKQuestionStep(identifier: "anxiousStep",
                                          title: "Question 2/4",
                                          question: "How anxious were you finding your way to this destination",
                                          answer: ORKValuePickerAnswerFormat(textChoices: multiAnswerChoices))
    let findingQuestion = ORKQuestionStep(identifier: "findQuestion",
                                          title: "Question 3/4",
                                          question: "How difficult was it to find this destination?",
                                          answer: ORKValuePickerAnswerFormat(textChoices: multiAnswerChoices))
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
