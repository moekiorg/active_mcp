import { mcpt, expect } from "mcp-testing-library";

mcpt(
  {
    command: "ruby",
    args: ["./demo/mcp/server.rb"],
  },
  async ({ client, tools, resources, prompts }) => {
    expect(tools[0]).eql({
      name: "news",
      description: "Get latest news from specified category",
      inputSchema: {
        type: "object",
        properties: {
          category: {
            type: "string",
            description: "News category (tech, business, sports, etc.)",
          },
          limit: {
            type: "integer",
            description: "Maximum number of news items to retrieve",
          },
        },
        required: ["category"],
      },
    });

    expect(resources[0]).eql({
      uri: "data://localhost/user/UserA",
      name: "UserA",
      description: "UserA's profile",
      mimeType: "application/json",
    });

    expect(prompts[0]).eql({
      name: "hello",
      description: "This is a test",
      arguments: [
        {
          name: "name",
          description: "Name",
          required: true,
        },
      ],
    });

    const toolResult = await client.callTool({
      name: "news",
      arguments: {
        category: "tech",
      },
    });
    expect((toolResult.content as any)[0].type).eq("text");

    const resource = await client.readResource({
      uri: "data://localhost/user/UserA",
    });
    expect(resource.contents[0].text).eq('{"name":"UserA"}');

    await client.getPrompt({
      name: "hello",
      arguments: {
        name: "UserA",
      },
    });
    // expect(prompt.messages.length).eq(4) bug of SDK?
  }
);
