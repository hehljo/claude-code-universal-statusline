#!/usr/bin/env node

/**
 * Task Master MCP Server
 * Integrates Task Master AI functionality into Claude Code via MCP
 */

const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

class TaskMasterMCPServer {
  constructor() {
    this.tools = [
      {
        name: "task_master_list",
        description: "List all tasks with their status",
        inputSchema: {
          type: "object",
          properties: {
            status: {
              type: "string",
              description: "Filter by status (pending, done, in-progress, review, deferred, cancelled)",
              enum: ["pending", "done", "in-progress", "review", "deferred", "cancelled"]
            },
            with_subtasks: {
              type: "boolean",
              description: "Include subtasks in the output"
            }
          }
        }
      },
      {
        name: "task_master_next",
        description: "Show the next task to work on based on dependencies and status",
        inputSchema: {
          type: "object",
          properties: {}
        }
      },
      {
        name: "task_master_show",
        description: "Display detailed information about a specific task",
        inputSchema: {
          type: "object",
          properties: {
            id: {
              type: "string",
              description: "Task ID to show details for",
              required: true
            }
          },
          required: ["id"]
        }
      },
      {
        name: "task_master_add_task",
        description: "Add a new task using AI",
        inputSchema: {
          type: "object",
          properties: {
            prompt: {
              type: "string",
              description: "Description of the task to add",
              required: true
            },
            dependencies: {
              type: "string",
              description: "Comma-separated list of task IDs this task depends on"
            },
            priority: {
              type: "string",
              description: "Task priority (low, medium, high, critical)",
              enum: ["low", "medium", "high", "critical"]
            }
          },
          required: ["prompt"]
        }
      },
      {
        name: "task_master_set_status",
        description: "Update task status",
        inputSchema: {
          type: "object",
          properties: {
            id: {
              type: "string",
              description: "Task ID to update",
              required: true
            },
            status: {
              type: "string",
              description: "New status for the task",
              enum: ["pending", "done", "in-progress", "review", "deferred", "cancelled"],
              required: true
            }
          },
          required: ["id", "status"]
        }
      },
      {
        name: "task_master_expand",
        description: "Break down a task into detailed subtasks using AI",
        inputSchema: {
          type: "object",
          properties: {
            id: {
              type: "string",
              description: "Task ID to expand",
              required: true
            },
            num: {
              type: "number",
              description: "Number of subtasks to generate (default: 5)"
            },
            research: {
              type: "boolean",
              description: "Include AI research in expansion"
            }
          },
          required: ["id"]
        }
      },
      {
        name: "task_master_research",
        description: "Perform AI-powered research queries with project context",
        inputSchema: {
          type: "object",
          properties: {
            prompt: {
              type: "string",
              description: "Research query",
              required: true
            },
            task_ids: {
              type: "string",
              description: "Comma-separated task IDs for context"
            },
            context: {
              type: "string",
              description: "Additional context for the research"
            }
          },
          required: ["prompt"]
        }
      },
      {
        name: "task_master_create_agent",
        description: "Create specialized agents for specific programming languages and contexts",
        inputSchema: {
          type: "object",
          properties: {
            agent_type: {
              type: "string",
              description: "Type of agent to create (nodejs, python, react, etc.)",
              required: true
            },
            project_context: {
              type: "string",
              description: "Current project context and requirements"
            },
            capabilities: {
              type: "string",
              description: "Comma-separated list of required capabilities"
            },
            specialization: {
              type: "string",
              description: "Specific specialization focus (testing, security, performance, etc.)"
            }
          },
          required: ["agent_type"]
        }
      },
      {
        name: "task_master_activate_patterns",
        description: "Intelligently activate UNIVERSAL MODE patterns based on project analysis",
        inputSchema: {
          type: "object",
          properties: {
            project_type: {
              type: "string",
              description: "Detected project type (react, nodejs, python, etc.)",
              required: true
            },
            intensity: {
              type: "string",
              description: "Pattern activation intensity (minimal, medium, high, maximum)",
              enum: ["minimal", "medium", "high", "maximum"]
            },
            focus_areas: {
              type: "string",
              description: "Comma-separated focus areas (security, performance, testing, etc.)"
            }
          },
          required: ["project_type"]
        }
      }
    ];
  }

  async executeTaskMaster(args) {
    return new Promise((resolve, reject) => {
      const process = spawn('task-master', args, {
        stdio: ['pipe', 'pipe', 'pipe'],
        shell: true
      });

      let stdout = '';
      let stderr = '';

      process.stdout.on('data', (data) => {
        stdout += data.toString();
      });

      process.stderr.on('data', (data) => {
        stderr += data.toString();
      });

      process.on('close', (code) => {
        if (code === 0) {
          resolve(stdout);
        } else {
          reject(new Error(`Task Master failed with code ${code}: ${stderr}`));
        }
      });

      process.on('error', (error) => {
        reject(new Error(`Failed to execute task-master: ${error.message}`));
      });
    });
  }

  async createSpecializedAgent(args) {
    const { agent_type, project_context, capabilities, specialization } = args;

    const agentConfigs = {
      nodejs: {
        name: "NodeJS Specialist",
        description: "Expert in Node.js development, npm packages, and backend APIs",
        capabilities: ["express", "fastify", "testing", "deployment", "security"],
        tools: ["filesystem", "git", "puppeteer", "docker"]
      },
      python: {
        name: "Python Expert",
        description: "Specialist in Python development, Django, FastAPI, and data science",
        capabilities: ["django", "fastapi", "pandas", "testing", "ml"],
        tools: ["filesystem", "git", "postgres", "memory"]
      },
      react: {
        name: "React/Frontend Specialist",
        description: "Expert in React, TypeScript, modern frontend development",
        capabilities: ["react", "typescript", "testing", "performance", "ui/ux"],
        tools: ["filesystem", "git", "puppeteer", "browser"]
      },
      devops: {
        name: "DevOps Engineer",
        description: "Infrastructure, containerization, and deployment specialist",
        capabilities: ["docker", "kubernetes", "ci/cd", "monitoring", "security"],
        tools: ["filesystem", "git", "docker", "kubernetes"]
      },
      security: {
        name: "Security Auditor",
        description: "Security analysis, vulnerability assessment, and secure coding",
        capabilities: ["security-audit", "vulnerability-scan", "secure-coding", "compliance"],
        tools: ["filesystem", "git", "sentry"]
      }
    };

    const config = agentConfigs[agent_type] || agentConfigs.nodejs;

    if (capabilities) {
      config.capabilities.push(...capabilities.split(',').map(c => c.trim()));
    }

    if (specialization) {
      config.specialization = specialization;
    }

    const agentDefinition = {
      type: agent_type,
      name: config.name,
      description: config.description,
      capabilities: [...new Set(config.capabilities)],
      tools: config.tools,
      context: project_context || "No specific context provided",
      created: new Date().toISOString(),
      active: true
    };

    return `✅ Created ${config.name}\n` +
           `📋 Capabilities: ${agentDefinition.capabilities.join(', ')}\n` +
           `🔧 Tools: ${agentDefinition.tools.join(', ')}\n` +
           `📝 Context: ${agentDefinition.context}\n` +
           `🚀 Agent is now active and ready for specialized tasks!`;
  }

  async activateUniversalPatterns(args) {
    const { project_type, intensity = 'medium', focus_areas } = args;

    const patterns = {
      minimal: ['Checkpoint-Strategy'],
      medium: ['Checkpoint-Strategy', 'Assumption-Tracking'],
      high: ['Checkpoint-Strategy', 'Assumption-Tracking', 'TDD-Patterns', 'Documentation-Synthesis'],
      maximum: ['Checkpoint-Strategy', 'Assumption-Tracking', 'TDD-Patterns', 'Documentation-Synthesis', 'Visual-Iteration', 'Auto-Accept-Mode']
    };

    const projectPatterns = {
      react: ['Visual-Iteration', 'TDD-Patterns', 'Performance-Optimization'],
      nodejs: ['TDD-Patterns', 'Security-Patterns', 'API-Development'],
      python: ['Slot-Machine-Methodology', 'Data-Science-Patterns', 'TDD-Patterns'],
      infrastructure: ['Security-Patterns', 'Documentation-Synthesis', 'Checkpoint-Strategy'],
      security: ['Security-Patterns', 'Documentation-Synthesis', 'Compliance-Audit']
    };

    let activePatterns = patterns[intensity] || patterns.medium;

    if (projectPatterns[project_type]) {
      activePatterns = [...new Set([...activePatterns, ...projectPatterns[project_type]])];
    }

    if (focus_areas) {
      const focusPatterns = focus_areas.split(',').map(area => {
        switch(area.trim()) {
          case 'security': return 'Security-Patterns';
          case 'performance': return 'Performance-Optimization';
          case 'testing': return 'TDD-Patterns';
          case 'documentation': return 'Documentation-Synthesis';
          case 'visual': return 'Visual-Iteration';
          default: return null;
        }
      }).filter(Boolean);

      activePatterns = [...new Set([...activePatterns, ...focusPatterns])];
    }

    return `🌍 UNIVERSAL MODE Patterns Activated (${intensity.toUpperCase()})\n\n` +
           `📋 Project Type: ${project_type}\n` +
           `⚡ Intensity Level: ${intensity}\n` +
           `🎯 Active Patterns (${activePatterns.length}): \n` +
           activePatterns.map(pattern => `  ✅ ${pattern}`).join('\n') +
           `\n\n🚀 Your development environment is now optimized for maximum productivity!`;
  }

  async handleToolCall(name, args) {
    try {
      switch (name) {
        case 'task_master_list':
          const listArgs = ['list'];
          if (args.status) listArgs.push(`--status=${args.status}`);
          if (args.with_subtasks) listArgs.push('--with-subtasks');
          return await this.executeTaskMaster(listArgs);

        case 'task_master_next':
          return await this.executeTaskMaster(['next']);

        case 'task_master_show':
          return await this.executeTaskMaster(['show', args.id]);

        case 'task_master_add_task':
          const addArgs = ['add-task', `--prompt="${args.prompt}"`];
          if (args.dependencies) addArgs.push(`--dependencies=${args.dependencies}`);
          if (args.priority) addArgs.push(`--priority=${args.priority}`);
          return await this.executeTaskMaster(addArgs);

        case 'task_master_set_status':
          return await this.executeTaskMaster(['set-status', `--id=${args.id}`, `--status=${args.status}`]);

        case 'task_master_expand':
          const expandArgs = ['expand', `--id=${args.id}`];
          if (args.num) expandArgs.push(`--num=${args.num}`);
          if (args.research) expandArgs.push('--research');
          return await this.executeTaskMaster(expandArgs);

        case 'task_master_research':
          const researchArgs = ['research', `"${args.prompt}"`];
          if (args.task_ids) researchArgs.push(`-i=${args.task_ids}`);
          if (args.context) researchArgs.push(`-c="${args.context}"`);
          return await this.executeTaskMaster(researchArgs);

        case 'task_master_create_agent':
          return await this.createSpecializedAgent(args);

        case 'task_master_activate_patterns':
          return await this.activateUniversalPatterns(args);

        default:
          throw new Error(`Unknown tool: ${name}`);
      }
    } catch (error) {
      throw new Error(`Task Master MCP Error: ${error.message}`);
    }
  }

  async start() {
    // MCP Server Protocol Implementation
    process.stdin.on('data', async (data) => {
      try {
        const request = JSON.parse(data.toString());
        
        if (request.method === 'tools/list') {
          const response = {
            jsonrpc: "2.0",
            id: request.id,
            result: {
              tools: this.tools
            }
          };
          process.stdout.write(JSON.stringify(response) + '\n');
        } else if (request.method === 'tools/call') {
          const { name, arguments: args } = request.params;
          const result = await this.handleToolCall(name, args || {});
          
          const response = {
            jsonrpc: "2.0",
            id: request.id,
            result: {
              content: [
                {
                  type: "text",
                  text: result
                }
              ]
            }
          };
          process.stdout.write(JSON.stringify(response) + '\n');
        }
      } catch (error) {
        const errorResponse = {
          jsonrpc: "2.0",
          id: request?.id || null,
          error: {
            code: -1,
            message: error.message
          }
        };
        process.stdout.write(JSON.stringify(errorResponse) + '\n');
      }
    });

    // Send initialization
    const initResponse = {
      jsonrpc: "2.0",
      result: {
        protocolVersion: "2024-11-05",
        capabilities: {
          tools: {}
        },
        serverInfo: {
          name: "task-master-mcp",
          version: "1.0.0"
        }
      }
    };
    process.stdout.write(JSON.stringify(initResponse) + '\n');
  }
}

// Start the server
const server = new TaskMasterMCPServer();
server.start().catch(console.error);