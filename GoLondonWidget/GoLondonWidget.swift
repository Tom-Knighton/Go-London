//
//  GoLondonWidget.swift
//  GoLondonWidget
//
//  Created by Tom Knighton on 25/11/2021.
//

import WidgetKit
import SwiftUI
import Intents


struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct DisruptionsEntry: TimelineEntry {
    var date = Date()
    
//    let lines: [Line]?
}

struct GoLondonWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    
    var entry: Provider.Entry

    var body: some View {
        VStack {
            if family == .systemLarge || family == .systemExtraLarge {
                Text("Line Disruptions:")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.blue)
            }
            Spacer()
            
        }
    }
}

@main
struct GoLondonWidget: WidgetBundle {
    let kind: String = "GoLondonWidget"

    var body: some Widget {
        GoLondonTubeStatusWidget()
    }
}

struct GoLondonTubeStatusWidget: Widget {
    let kind: String = "TubeStatusWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            GoLondonWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
        .configurationDisplayName("Line Disruptions")
        .description("A quick overview of any disruptions")
    } 
}
