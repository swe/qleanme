import Foundation
import Supabase

public enum UserType {
    case user
    case worker
    case newUser
}

public struct FAQ: Codable, Identifiable {
    public let id: Int
    public let question: String
    public let answer: String
}

public enum NetworkError: Error {
    case decodingError(String)
    case serverError(String)
}

public class NetworkManager {
    public static let shared = NetworkManager()
    
    private let supabase: SupabaseClient
    
    public private(set) var currentUserType: UserType = .newUser
    
    private init() {
        let supabaseURL = URL(string: "https://test.supabase.co")!
        let supabaseKey = "test"
        
        self.supabase = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
    
    public func checkUserExistence(phoneNumber: String) async throws -> String {
        let usersQuery = supabase
            .from("users")
            .select("full_name")
            .eq("phone_number", value: phoneNumber)
            .limit(1)
        
        let usersResponse: [User] = try await usersQuery.execute().value
        
        if let user = usersResponse.first {
            currentUserType = .user
            return "User found: \(user.fullName)"
        }
        
        let workersQuery = supabase
            .from("workers")
            .select("full_name")
            .eq("phone_number", value: phoneNumber)
            .limit(1)
        
        let workersResponse: [Worker] = try await workersQuery.execute().value
        
        if let worker = workersResponse.first {
            currentUserType = .worker
            return "Worker found: \(worker.fullName) is a worker"
        }
        
        currentUserType = .newUser
        return "Opa! Something new"
    }
    
    public func fetchFAQs() async throws -> [FAQ] {
        let query = supabase
            .from("faq")
            .select("id, question, answer")
        
        do {
            let response: PostgrestResponse<[FAQ]> = try await query.execute()
            print("Raw Supabase response: \(response)")
            
            let faqs = response.value
            
            // Print the fetched FAQs for debugging
            print("Fetched FAQs:")
            for faq in faqs {
                print("ID: \(faq.id), Question: \(faq.question), Answer: \(faq.answer)")
            }
            
            return faqs
        } catch {
            print("Raw error: \(error)")
            if let decodingError = error as? DecodingError {
                throw NetworkError.decodingError("Failed to decode FAQ data: \(decodingError.localizedDescription)")
            } else {
                throw NetworkError.serverError("Failed to fetch FAQs: \(error.localizedDescription)")
            }
        }
    }

    public func fetchOrders(for userId: Int) async throws -> [Order] {
        let ordersQuery = supabase
            .from("orders")
            .select()
            .eq("user_id", value: userId)
            .order("date_time", ascending: false)

        do {
            let response: PostgrestResponse<[Order]> = try await ordersQuery.execute()
            return response.value
        } catch {
            print("Detailed error in fetchOrders: \(error)")
            throw NetworkError.serverError("Failed to fetch orders: \(error.localizedDescription)")
        }
    }

    public func fetchOrderAddons(for orderId: UUID) async throws -> [OrderAddon] {
        let addonsQuery = supabase
            .from("order_addons")
            .select()
            .eq("order_id", value: orderId)

        do {
            let response: PostgrestResponse<[OrderAddon]> = try await addonsQuery.execute()
            return response.value
        } catch {
            print("Detailed error in fetchOrderAddons: \(error)")
            throw NetworkError.serverError("Failed to fetch order addons: \(error.localizedDescription)")
        }
    }

    public func fetchWorker(with id: Int) async throws -> PublicWorker {
        let query = supabase
            .from("workers")
            .select()
            .eq("id", value: id)
            .single()

        do {
            let response: PostgrestResponse<Worker> = try await query.execute()
            return PublicWorker(from: response.value)
        } catch {
            throw NetworkError.serverError("Failed to fetch worker: \(error.localizedDescription)")
        }
    }

    public func cancelOrder(orderId: UUID) async throws {
        let query = supabase
            .from("orders")
            .delete()
            .eq("id", value: orderId)

        do {
            try await query.execute()
        } catch {
            throw NetworkError.serverError("Failed to cancel order: \(error.localizedDescription)")
        }
    }
}

// Internal types
struct User: Codable {
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
    }
}

struct Worker: Codable {
    let id: Int
    let fullName: String
    let phoneNumber: String
    let email: String
    let amountOfOrders: Int
    let totalRating: Decimal
    let workerLevel: String
    let bio: String
    let yearsOfExperience: Int
    let workerType: String
    let photoUrl: String

    enum CodingKeys: String, CodingKey {
        case id, email, bio
        case fullName = "full_name"
        case phoneNumber = "phone_number"
        case amountOfOrders = "amount_of_orders"
        case totalRating = "total_rating"
        case workerLevel = "worker_level"
        case yearsOfExperience = "years_of_experience"
        case workerType = "worker_type"
        case photoUrl = "photo_url"
    }
}

public struct Order: Codable, Identifiable {
    public let id: UUID
    public let userId: Int
    public let cleanerId: Int
    public let type: String
    public let status: String
    public let dateTime: Date
    public let address: String
    public let price: Decimal
    public let isCompleted: Bool
    public let rating: Int?
    public let receiptUrl: String?
    public let duration: Int
    public let specialInstructions: String?

    enum CodingKeys: String, CodingKey {
        case id, type, status, address, price, duration
        case userId = "user_id"
        case cleanerId = "cleaner_id"
        case dateTime = "date_time"
        case isCompleted = "is_completed"
        case rating
        case receiptUrl = "receipt_url"
        case specialInstructions = "special_instructions"
    }
}

public struct OrderAddon: Codable, Identifiable {
    public let id: Int
    public let orderId: UUID
    public let addon: String

    enum CodingKeys: String, CodingKey {
        case id
        case orderId = "order_id"
        case addon
    }
}

public struct PublicWorker {
    public let id: Int
    public let fullName: String
    public let photoUrl: String
    public let rating: Double

    init(from worker: Worker) {
        self.id = worker.id
        self.fullName = worker.fullName
        self.photoUrl = worker.photoUrl
        self.rating = worker.amountOfOrders > 0 ? (worker.totalRating as NSDecimalNumber).doubleValue / Double(worker.amountOfOrders) : 0.0
    }
}
