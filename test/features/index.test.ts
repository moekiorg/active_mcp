import { mcpt, expect } from "mcp-testing-library";

mcpt(
  {
    command: "ruby",
    args: ["./demo/mcp/server.rb"],
  },
  async ({ tools }) => {
    expect(tools.find((tool) => tool.name === "weather")).not.to.be.undefined;
  }
);
