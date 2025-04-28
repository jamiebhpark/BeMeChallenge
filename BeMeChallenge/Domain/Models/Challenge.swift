// Domain/Models/Challenge.swift
import Foundation
import FirebaseFirestore

public enum ChallengeType: String, Codable {
  case mandatory = "필수"
  case open      = "오픈"
}

public struct Challenge: Identifiable, Codable {
  public var id: String
  public var title: String
  public var description: String
  public var participantsCount: Int
  public var endDate: Date
  public var type: ChallengeType

  public init?(document: QueryDocumentSnapshot) {
    let data = document.data()
    guard
      let title       = data["title"]            as? String,
      let desc        = data["description"]      as? String,
      let count       = data["participantsCount"]as? Int,
      let endTs       = data["endDate"]          as? Timestamp,
      let rawType     = data["type"]             as? String,
      let type        = ChallengeType(rawValue: rawType)
    else { return nil }

    self.id                = document.documentID
    self.title             = title
    self.description       = desc
    self.participantsCount = count
    self.endDate           = endTs.dateValue()
    self.type              = type
  }
}
