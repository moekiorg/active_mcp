---
title: Introduction
description: Introduction to Active MCP
---

# Introduction to Active MCP

Active MCP is a plugin that allows defining Model Context Protocol schemas in Ruby on Rails.

Active MCP has two sections: one defines MCP schemas through the Rails engine, and the other provides a class that implements an MCP server script compatible with **STDIO transport**. This allows Rails applications to work with the current standard STDIO transport.

The development of Active MCP was motivated by the belief that **MCP schemas should be dynamic**. Current mainstream MCP servers that integrate with web applications typically define MCP schemas using static objects that trace GraphQL or REST API schemas. Another approach is to mechanically generate MCP schemas by reading a web application's GraphQL API or REST API.

There are two problems with these methods. First, since the MCP schema cannot be changed based on user permissions or state, it results in providing unnecessary tool and resource lists to the LLM. Second, GraphQL and REST APIs may not necessarily offer features or parameters that are suitable for LLMs.

Active MCP solves these issues by dynamically defining MCP schemas based on the context provided by the application.

Additionally, a problem with implementing MCP servers that use part of the web server is that they cannot work with the currently prevalent STDIO transport. As mentioned earlier, Active MCP addresses this issue by preparing a separate process for the MCP server. It also supports HTTP transport, allowing for smooth transition to future standards.

Furthermore, Active MCP currently only exhibits completely stateless behavior. This is for several reasons: server configuration would become complex, major MCP clients don't fully support this behavior, and we haven't yet identified clear benefits from stateful behavior.

## Getting Started

Ready to integrate Active MCP into your project? Check out the [Installation](./installation) guide to get started quickly.
