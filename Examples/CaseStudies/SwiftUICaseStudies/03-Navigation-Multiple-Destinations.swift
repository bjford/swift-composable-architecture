import ComposableArchitecture
import SwiftUI

private let readMe = """
  This screen demonstrates driving 3 kinds of navigation (drill down, sheet, popover) from a single
  piece of enum state.
  """

@Reducer
struct MultipleDestinations {
  @Reducer
  public struct Destination {
    @ObservableState
    public enum State: Equatable {
      case drillDown(Counter.State)
      case popover(Counter.State)
      case sheet(Counter.State)
    }

    public enum Action {
      case drillDown(Counter.Action)
      case popover(Counter.Action)
      case sheet(Counter.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: \.drillDown, action: \.drillDown) {
        Counter()
      }
      Scope(state: \.sheet, action: \.sheet) {
        Counter()
      }
      Scope(state: \.popover, action: \.popover) {
        Counter()
      }
    }
  }

  @ObservableState
  struct State: Equatable {
    @Presents var destination: Destination.State?
  }

  enum Action {
    case destination(PresentationAction<Destination.Action>)
    case showDrillDown
    case showPopover
    case showSheet
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .showDrillDown:
        state.destination = .drillDown(Counter.State())
        return .none
      case .showPopover:
        state.destination = .popover(Counter.State())
        return .none
      case .showSheet:
        state.destination = .sheet(Counter.State())
        return .none
      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination) {
      Destination()
    }
  }
}

struct MultipleDestinationsView: View {
  @Bindable var store: StoreOf<MultipleDestinations>

  var body: some View {
    Form {
      Section {
        AboutView(readMe: readMe)
      }
      Button("Show drill-down") {
        store.send(.showDrillDown)
      }
      Button("Show popover") {
        store.send(.showPopover)
      }
      Button("Show sheet") {
        store.send(.showSheet)
      }
    }
    .navigationDestination(
      item: $store.scope(state: \.destination?.drillDown, action: \.destination.drillDown)
    ) { store in
      CounterView(store: store)
    }
    .popover(
      item: $store.scope(state: \.destination?.popover, action: \.destination.popover)
    ) { store in
      CounterView(store: store)
    }
    .sheet(
      item: $store.scope(state: \.destination?.sheet, action: \.destination.sheet)
    ) { store in
      CounterView(store: store)
    }
  }
}
