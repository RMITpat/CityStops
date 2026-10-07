import Foundation

/// Mock trip service used by UI tests.
/// It does not read from or write to Firestore.
@MainActor
final class MockTripService: TripService {
    private let pageSize = 4

    private var dummyTrips: [Trip] = [
        Trip(
            id: "test1",
            ownerUsername: "Tester",
            ownerId: "1",
            name: "Sydney Food Trail",
            description: "Explore cafés, restaurants and local food markets around Sydney.",
            places: [],
            preferences: ["Food"]
        ),

        Trip(
            id: "test2",
            ownerUsername: "Test2",
            ownerId: "test2",
            name: "Sydney Landmarks",
            description: "Visit famous landmarks and historical sites around the harbour.",
            places: [],
            preferences: ["Landmarks and Sightseeing"],
            savedByUser: true
        ),

        Trip(
            id: "test3",
            ownerUsername: "Test3",
            ownerId: "test3",
            name: "Sydney Shopping Day",
            description: "Spend the day exploring popular shopping areas and markets.",
            places: [],
            preferences: ["Shopping"],
            savedByUser: true
        ),

        Trip(
            id: "test4",
            ownerUsername: "Tester",
            ownerId: "1",
            name: "Sydney Nature Escape",
            description: "Discover parks, gardens, beaches and scenic natural locations.",
            places: [],
            preferences: ["Nature"]
        ),

        Trip(
            id: "test5",
            ownerUsername: "Test5",
            ownerId: "test5",
            name: "Sydney Sports and Fun",
            description: "Find sporting venues, amusement areas and fun activities.",
            places: [],
            preferences: ["Sports and Amusement"]
        ),

        Trip(
            id: "test6",
            ownerUsername: "Test6",
            ownerId: "test6",
            name: "Complete Sydney Experience",
            description: "A mixed daytrip combining food, landmarks, shopping and nature.",
            places: [],
            preferences: [
                "Food",
                "Landmarks and Sightseeing",
                "Shopping",
                "Nature",
                "Sports and Amusement"
            ]
        ),

        Trip(
            id: "test7",
            ownerUsername: "Test7",
            ownerId: "test7",
            name: "Harbour and History",
            description: "Explore Sydney Harbour while visiting historic and cultural locations.",
            places: [],
            preferences: [
                "Landmarks and Sightseeing",
                "Nature"
            ]
        ),

        Trip(
            id: "test8",
            ownerUsername: "Tester",
            ownerId: "1",
            name: "Food and Shopping Weekend",
            description: "Enjoy local restaurants followed by a relaxed shopping trip.",
            places: [],
            preferences: [
                "Food",
                "Shopping"
            ]
        )
    ]

    private var tripFeedIndex = 0
    private var userTripsIndex = 0
    private var savedTripsIndex = 0


    private func nextPage(
        from trips: [Trip],
        index: inout Int
    ) -> [Trip] {
        guard index < trips.count else {
            return []
        }

        let endIndex = min(index + pageSize, trips.count)
        let page = Array(trips[index..<endIndex])

        index = endIndex
        return page
    }


    func loadTrips(ownerId: String) async throws -> [Trip] {
        nextPage(
            from: dummyTrips,
            index: &tripFeedIndex
        )
    }


    func loadUserTrips(ownerId: String) async throws -> [Trip] {
        let userTrips = dummyTrips.filter {
            $0.ownerId == ownerId
        }

        return nextPage(
            from: userTrips,
            index: &userTripsIndex
        )
    }

    func loadSavedTrips(ownerId: String) async throws -> [Trip] {
        let savedTrips = dummyTrips.filter {
            $0.savedByUser
        }

        return nextPage(
            from: savedTrips,
            index: &savedTripsIndex
        )
    }

    func saveTrip(trip: Trip) async throws {
        var newTrip = trip
        newTrip.id = "test\(dummyTrips.count+1)"
        dummyTrips.insert(newTrip, at: 0)
        resetPagination()
    }


    func bookmarkTrip(
        ownerId: String,
        tripId: String
    ) async throws {
        guard let index = dummyTrips.firstIndex(where: {
            $0.id == tripId
        }) else {
            return
        }

        dummyTrips[index].savedByUser = true
        savedTripsIndex = 0
    }

    func removeTripBookmark(
        ownerId: String,
        tripId: String
    ) async throws {
        guard let index = dummyTrips.firstIndex(where: {
            $0.id == tripId
        }) else {
            return
        }

        dummyTrips[index].savedByUser = false
        savedTripsIndex = 0
    }

    func deleteTrip(tripId: String) async throws {
        dummyTrips.removeAll {
            $0.id == tripId
        }

        resetPagination()
    }

    func clearLastTripFeedDocument() {
        tripFeedIndex = 0
    }

    func clearLastUserTripDocument() {
        userTripsIndex = 0
    }

    func clearLastSavedTripDocument() {
        savedTripsIndex = 0
    }

    private func resetPagination() {
        tripFeedIndex = 0
        userTripsIndex = 0
        savedTripsIndex = 0
    }
}
