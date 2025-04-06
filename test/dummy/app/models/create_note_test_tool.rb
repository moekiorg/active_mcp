class CreateNoteTestTool < ActiveMcp::Tool
  description "Create a new test note"

  argument :title, :string, required: true, description: "Title of the note"
  argument :content, :string, required: true, description: "Content of the note"

  def call(title:, content:)
    note = TestNote.create(title: title, content: content)

    if note.persisted?
      {
        type: "text",
        content: "Note created successfully with ID: #{note.id}"
      }
    else
      raise "Failed to create note: #{note.errors.full_messages.join(", ")}"
    end
  end
end
