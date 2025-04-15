// CalendarView.swift
import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    private let days = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        VStack {
            // 요일 헤더
            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            // 달력 셀 그리드
            let dates = viewModel.currentMonthDates()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(dates, id: \.self) { date in
                    CalendarCell(
                        date: date,
                        participated: viewModel.participationDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                    )
                }
            }
        }
        .padding()
    }
}

struct CalendarCell: View {
    var date: Date
    var participated: Bool
    
    var body: some View {
        Text("\(Calendar.current.component(.day, from: date))")
            .frame(maxWidth: .infinity, maxHeight: 40)
            .background(participated ? Color.green.opacity(0.5) : Color.clear)
            .cornerRadius(4)
    }
}
