import Foundation

public class Stadium {
	public var team : String?
	public var address : String?
	public var lat : Double?
	public var lng : Double?


    public class func modelsFromDictionaryArray(array:[[String: AnyObject]]) -> [Stadium] {
        return array.flatMap(Stadium.init)
    }

	required public init?(dictionary: [String: AnyObject]) {

		team = dictionary["team"] as? String
		address = dictionary["address"] as? String
		lat = dictionary["lat"] as? Double
		lng = dictionary["lng"] as? Double
	}

	public func dictionaryRepresentation() -> [String: AnyObject] {

        return ["team": self.team as AnyObject,
                "address": self.address as AnyObject,
                "lat": self.lat as AnyObject,
                "lng": self.lng as AnyObject]
	}

}
