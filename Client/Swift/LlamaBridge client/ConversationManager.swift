import Foundation

struct ConversationEntry: Codable, Identifiable {
    let id: UUID
    let prompt: String
    let response: String
    
    init(id: UUID = UUID(), prompt: String, response: String) {
        self.id = id
        self.prompt = prompt
        self.response = response
    }
}

class ConversationManager: ObservableObject {
    @Published var conversations: [String: [ConversationEntry]] = [:]
    @Published var sessionNames: [String: String] = [:]
    
    private let conversationsFilename = "conversations.json"
    private let sessionNamesFilename = "sessionNames.json"
    
    init() {
        loadConversations()
        loadSessionNames()
    }
    
    func loadConversations() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(conversationsFilename) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            conversations = try JSONDecoder().decode([String: [ConversationEntry]].self, from: data)
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
    
    func saveConversations() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(conversationsFilename) else { return }
        
        do {
            let data = try JSONEncoder().encode(conversations)
            try data.write(to: url)
        } catch {
            print("Error saving conversations: \(error)")
        }
    }
    
    func formatConversation(conversation: [ConversationEntry]) -> String {
        return conversation.map { "User: \($0.prompt)\nAI: \($0.response)\n" }.joined()
    }
    
    func getSessionName(for sessionId: String) -> String {
        return sessionNames[sessionId] ?? "Untitled Chat"
    }
    
    func renameSession(sessionId: String, newName: String) {
        sessionNames[sessionId] = newName
        saveSessionNames()
    }
    
    func addToConversation(sessionId: String, prompt: String, response: String) {
        if conversations[sessionId] == nil {
            conversations[sessionId] = []
        }
        conversations[sessionId]?.append(ConversationEntry(prompt: prompt, response: response))
        saveConversations()
    }
    
    func saveSessionNames() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(sessionNamesFilename) else { return }
        
        do {
            let data = try JSONEncoder().encode(sessionNames)
            try data.write(to: url)
        } catch {
            print("Error saving session names: \(error)")
        }
    }
    
    func loadSessionNames() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(sessionNamesFilename) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            sessionNames = try JSONDecoder().decode([String: String].self, from: data)
        } catch {
            print("Error loading session names: \(error)")
        }
    }
}