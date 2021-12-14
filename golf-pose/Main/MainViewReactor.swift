//
//  MainViewReactor.swift
//  golf-pose
//
//  Created by 이동현 on 2021/12/11.
//

import ReactorKit
import RxSwift

final class MainViewReactor: Reactor {
    enum MainState {
        case idle
        case recording
        case processing
        case analyzing
    }

    struct State {
        var mainState: MainState = .idle
    }

    enum Action {
        case setState(MainState)
    }

    enum Mutation {
        case setState(MainState)
    }

    let initialState: State

    init() {
        self.initialState = State()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setState(let mainState):
            return .just(.setState(mainState))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setState(let mainState):
            newState.mainState = mainState
        }
        return newState
    }
}
