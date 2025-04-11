import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Active MCP",
  description: "Rails engine for the Model Context Protocol (MCP)",
  lastUpdated: true,
  themeConfig: {
    logo: "/logo.png",
    nav: [
      { text: "Home", link: "/" },
      { text: "Guide", link: "/guide/" },
    ],
    socialLinks: [
      { icon: "github", link: "https://github.com/moekiorg/active_mcp" },
    ],

    sidebar: {
      "/guide/": [
        {
          text: "Getting Started",
          items: [
            { text: "Introduction", link: "/guide/" },
            { text: "Installation", link: "/guide/installation" },
            { text: "Configuration", link: "/guide/configuration" },
            { text: "Basic Usage", link: "/guide/basic-usage" },
            { text: "Tools", link: "/guide/tools" },
            { text: "Resources", link: "/guide/resources" },
            { text: "Prompts", link: "/guide/prompts" },
          ],
        },
        {
          text: "API Reference",
          items: [
            { text: "Schemas", link: "/guide/api/schemas" },
            { text: "Tools", link: "/guide/api/tools" },
            { text: "Resources", link: "/guide/api/resources" },
            { text: "Prompts", link: "/guide/api/prompts" },
            { text: "Messages", link: "/guide/api/messages" },
            { text: "Controller", link: "/guide/api/controller" },
          ],
        },
      ],
    },

    footer: {
      message: "Released under the MIT License.",
      copyright: "Copyright © 2025-present Moeki Kawakami",
    },
  },
});
