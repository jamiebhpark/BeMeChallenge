// CalendarView.swift
import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    private let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        VStack {
            // 요일 헤더
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            // 날짜 그리드: 달력처럼 날짜를 배치합니다.
            let dates = viewModel.monthDates()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<dates.count, id: \.self) { index in
                    CalendarCell(date: dates[index],
                                 participated: {
                                    // 날짜가 nil이 아니면 참여 여부를 체크
                                    if let cellDate = dates[index] {
                                        return viewModel.participationDates.contains {
                                            Calendar.current.isDate($0, inSameDayAs: cellDate)
                                        }
                                    }
                                    return false
                                 }())
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    struct CalendarCell: View {
        var date: Date?
        var participated: Bool
        
        var body: some View {
            Group {
                if let date = date {
                    // 날짜가 있는 경우: 참여 여부에 따라 배경색을 변경하여 강조
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.body)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(
                            participated ? Color.green.opacity(0.5) : Color.clear
                        )
                        .cornerRadius(4)
                } else {
                    // 날짜가 없는 빈 셀
                    Text("")
                        .frame(maxWidth: .infinity, maxHeight: 40)
                }
            }
        }
    }
}
