---
name: cross-team-communication
version: 1.0.0
description: Facilitates effective communication between development teams and agents
author: PrintCraft AI Team
tags:
  - collaboration
  - communication
  - coordination
  - workflow
---

# Cross-Team Communication Skill

## Overview
This skill enables effective communication and coordination between different development teams and agents, ensuring smooth collaboration, clear handoffs, and efficient problem resolution.

## Core Competencies

### 1. Communication Protocols

#### Message Format Standards
```typescript
interface TeamMessage {
  // Message metadata
  id: string;
  timestamp: Date;
  priority: 'low' | 'medium' | 'high' | 'critical';
  
  // Routing information
  from: {
    team: TeamIdentifier;
    agent: string;
    role: string;
  };
  to: {
    team: TeamIdentifier;
    agent?: string;
    broadcast?: boolean;
  };
  
  // Message content
  type: MessageType;
  subject: string;
  body: MessageContent;
  
  // Tracking
  requiresResponse: boolean;
  responseDeadline?: Date;
  thread?: string;
  references?: string[];
}

type MessageType = 
  | 'request'
  | 'response'
  | 'notification'
  | 'escalation'
  | 'handoff'
  | 'review'
  | 'approval'
  | 'update';

interface MessageContent {
  summary: string;
  details: any;
  attachments?: Attachment[];
  actionItems?: ActionItem[];
}
```

#### Communication Channels
```typescript
export class CommunicationHub {
  private channels: Map<string, Channel> = new Map([
    ['flutter-backend', new DirectChannel('flutter', 'backend')],
    ['backend-infrastructure', new DirectChannel('backend', 'infrastructure')],
    ['all-teams', new BroadcastChannel(['flutter', 'backend', 'shared'])],
    ['emergency', new PriorityChannel('emergency', 'critical')],
  ]);
  
  async sendMessage(message: TeamMessage): Promise<MessageResult> {
    // Validate message format
    this.validateMessage(message);
    
    // Determine routing
    const channel = this.determineChannel(message);
    
    // Apply communication rules
    const processedMessage = await this.applyRules(message);
    
    // Send through appropriate channel
    const result = await channel.send(processedMessage);
    
    // Track message
    await this.trackMessage(message, result);
    
    return result;
  }
  
  private applyRules(message: TeamMessage): TeamMessage {
    // Priority escalation
    if (message.type === 'escalation') {
      message.priority = 'high';
    }
    
    // Add context for cross-team messages
    if (message.from.team !== message.to.team) {
      message.body.details.context = this.gatherContext(message);
    }
    
    // Set response deadline if not specified
    if (message.requiresResponse && !message.responseDeadline) {
      message.responseDeadline = this.calculateDeadline(message.priority);
    }
    
    return message;
  }
}
```

### 2. Handoff Procedures

#### Task Handoff Protocol
```typescript
export class TaskHandoff {
  async initiateHandoff(
    task: Task,
    fromTeam: Team,
    toTeam: Team,
    reason: HandoffReason
  ): Promise<HandoffResult> {
    // Prepare handoff package
    const handoffPackage = await this.prepareHandoffPackage(task, fromTeam);
    
    // Validate handoff readiness
    const validation = await this.validateHandoff(handoffPackage, toTeam);
    if (!validation.ready) {
      return {
        success: false,
        issues: validation.issues,
      };
    }
    
    // Create handoff record
    const handoffId = await this.createHandoffRecord({
      task,
      fromTeam,
      toTeam,
      reason,
      package: handoffPackage,
      timestamp: new Date(),
    });
    
    // Send handoff notification
    await this.notifyHandoff(handoffId, toTeam);
    
    // Wait for acknowledgment
    const ack = await this.waitForAcknowledgment(handoffId, {
      timeout: 300000, // 5 minutes
    });
    
    if (ack.accepted) {
      // Transfer ownership
      await this.transferOwnership(task, toTeam);
      
      // Archive handoff
      await this.archiveHandoff(handoffId);
      
      return {
        success: true,
        handoffId,
        acknowledgedBy: ack.agent,
      };
    } else {
      // Handle rejection
      await this.handleRejection(handoffId, ack.reason);
      
      return {
        success: false,
        reason: ack.reason,
      };
    }
  }
  
  private async prepareHandoffPackage(
    task: Task,
    fromTeam: Team
  ): Promise<HandoffPackage> {
    return {
      task: {
        id: task.id,
        title: task.title,
        description: task.description,
        requirements: task.requirements,
        constraints: task.constraints,
        priority: task.priority,
        deadline: task.deadline,
      },
      
      context: {
        background: await this.gatherBackground(task),
        decisions: await this.getRelatedDecisions(task),
        dependencies: await this.analyzeDependencies(task),
        risks: await this.identifyRisks(task),
      },
      
      progress: {
        completedSteps: await this.getCompletedWork(task),
        currentStatus: task.status,
        blockers: await this.getCurrentBlockers(task),
        nextSteps: await this.suggestNextSteps(task),
      },
      
      artifacts: {
        documents: await this.collectDocuments(task),
        code: await this.collectCodeArtifacts(task),
        tests: await this.collectTests(task),
        configs: await this.collectConfigurations(task),
      },
      
      communication: {
        previousDiscussions: await this.getDiscussionHistory(task),
        keyContacts: await this.identifyKeyContacts(task),
        escalationPath: await this.defineEscalationPath(task),
      },
    };
  }
}
```

### 3. Conflict Resolution

#### Conflict Detection and Resolution
```typescript
export class ConflictResolver {
  private strategies: Map<ConflictType, ResolutionStrategy> = new Map([
    ['technical_disagreement', new TechnicalMediationStrategy()],
    ['resource_conflict', new ResourceNegotiationStrategy()],
    ['priority_conflict', new PriorityArbitrationStrategy()],
    ['dependency_conflict', new DependencyResolutionStrategy()],
  ]);
  
  async resolveConflict(conflict: Conflict): Promise<Resolution> {
    // Classify conflict type
    const type = this.classifyConflict(conflict);
    
    // Get appropriate strategy
    const strategy = this.strategies.get(type);
    
    // Gather all perspectives
    const perspectives = await this.gatherPerspectives(conflict);
    
    // Attempt automated resolution
    let resolution = await strategy.attemptResolution(conflict, perspectives);
    
    // If automated resolution fails, escalate
    if (!resolution.resolved) {
      resolution = await this.escalateToOrchestrator(conflict, perspectives);
    }
    
    // Document resolution
    await this.documentResolution(conflict, resolution);
    
    // Notify all parties
    await this.notifyResolution(conflict, resolution);
    
    return resolution;
  }
  
  private async gatherPerspectives(
    conflict: Conflict
  ): Promise<Perspective[]> {
    const perspectives: Perspective[] = [];
    
    for (const party of conflict.parties) {
      const perspective = await this.requestPerspective(party, conflict);
      perspectives.push({
        party,
        viewpoint: perspective.viewpoint,
        evidence: perspective.evidence,
        proposedSolution: perspective.proposedSolution,
        constraints: perspective.constraints,
      });
    }
    
    return perspectives;
  }
}

class TechnicalMediationStrategy implements ResolutionStrategy {
  async attemptResolution(
    conflict: Conflict,
    perspectives: Perspective[]
  ): Promise<Resolution> {
    // Analyze technical merits
    const analysis = await this.analyzeTechnicalMerits(perspectives);
    
    // Find common ground
    const commonGround = this.findCommonGround(perspectives);
    
    // Generate compromise options
    const options = await this.generateCompromiseOptions(
      analysis,
      commonGround
    );
    
    // Evaluate options
    const bestOption = await this.evaluateOptions(options, perspectives);
    
    if (bestOption.consensusScore > 0.8) {
      return {
        resolved: true,
        solution: bestOption.solution,
        rationale: bestOption.rationale,
        compromises: bestOption.compromises,
      };
    }
    
    return {
      resolved: false,
      attemptedSolutions: options,
      blockers: this.identifyBlockers(perspectives),
    };
  }
}
```

### 4. Status Synchronization

#### Cross-Team Status Updates
```typescript
export class StatusSynchronizer {
  private updateSchedule = {
    daily: ['09:00', '17:00'],
    weekly: ['monday-10:00'],
    critical: 'immediate',
  };
  
  async broadcastStatus(
    team: Team,
    status: TeamStatus
  ): Promise<void> {
    // Format status update
    const update = this.formatStatusUpdate(team, status);
    
    // Determine recipients
    const recipients = await this.determineRecipients(team, status);
    
    // Add relevant metrics
    update.metrics = await this.gatherMetrics(team, status.period);
    
    // Include visual elements
    update.visualizations = await this.generateVisualizations(update);
    
    // Send to all recipients
    await this.sendToRecipients(update, recipients);
    
    // Update dashboard
    await this.updateDashboard(team, update);
  }
  
  private formatStatusUpdate(
    team: Team,
    status: TeamStatus
  ): StatusUpdate {
    return {
      team: team.name,
      period: status.period,
      timestamp: new Date(),
      
      summary: {
        health: status.health,
        velocity: status.velocity,
        blockers: status.blockers.length,
        achievements: status.achievements,
      },
      
      progress: {
        tasksCompleted: status.tasksCompleted,
        tasksInProgress: status.tasksInProgress,
        tasksQueued: status.tasksQueued,
        milestones: status.milestoneProgress,
      },
      
      issues: status.blockers.map(blocker => ({
        id: blocker.id,
        description: blocker.description,
        impact: blocker.impact,
        needsHelpFrom: blocker.needsHelpFrom,
        proposedSolution: blocker.proposedSolution,
      })),
      
      upcoming: {
        nextMilestone: status.nextMilestone,
        dependencies: status.upcomingDependencies,
        risks: status.identifiedRisks,
      },
    };
  }
}
```

### 5. Knowledge Sharing

#### Cross-Team Learning
```typescript
export class KnowledgeSharing {
  async shareKnowledge(
    knowledge: Knowledge,
    sourceTeam: Team,
    targetTeams: Team[]
  ): Promise<void> {
    // Package knowledge appropriately
    const package = await this.packageKnowledge(knowledge, targetTeams);
    
    // Create learning materials
    const materials = await this.createLearningMaterials(package);
    
    // Schedule knowledge transfer session
    const session = await this.scheduleSession({
      topic: knowledge.topic,
      presenter: sourceTeam,
      attendees: targetTeams,
      duration: this.estimateDuration(knowledge),
      materials,
    });
    
    // Send pre-session materials
    await this.distributeMaterials(session);
    
    // Document in knowledge base
    await this.updateKnowledgeBase(knowledge, materials);
  }
  
  private async createLearningMaterials(
    knowledge: KnowledgePackage
  ): Promise<LearningMaterials> {
    return {
      overview: this.createOverview(knowledge),
      
      documentation: {
        concepts: this.documentConcepts(knowledge.concepts),
        procedures: this.documentProcedures(knowledge.procedures),
        examples: this.createExamples(knowledge.examples),
        exercises: this.createExercises(knowledge.topic),
      },
      
      code: {
        samples: this.preparCodeSamples(knowledge.code),
        playground: this.createPlayground(knowledge.topic),
        templates: this.createTemplates(knowledge.patterns),
      },
      
      media: {
        diagrams: await this.createDiagrams(knowledge.architecture),
        recordings: await this.prepareRecordings(knowledge.demos),
        slides: await this.createPresentation(knowledge),
      },
    };
  }
}
```

## Best Practices

### 1. Clear Communication Guidelines

```typescript
export const CommunicationGuidelines = {
  // Message clarity
  messageStructure: {
    subject: 'Clear, specific subject line',
    summary: 'TL;DR in first paragraph',
    details: 'Structured with headings',
    actionItems: 'Explicit next steps',
  },
  
  // Response expectations
  responseTime: {
    critical: '15 minutes',
    high: '1 hour',
    medium: '4 hours',
    low: '24 hours',
  },
  
  // Escalation triggers
  escalationCriteria: {
    noResponse: 'After 2x expected response time',
    blocked: 'When blocking other teams',
    conflict: 'When consensus cannot be reached',
    risk: 'When risk level increases',
  },
};
```

### 2. Documentation Standards

```markdown
# Cross-Team Communication Template

## Request/Update Type
[Request | Update | Escalation | Handoff]

## Summary
[One paragraph summary of the communication]

## Context
- **Originating Team**: [Team name]
- **Related Task/Project**: [ID and name]
- **Priority**: [Critical | High | Medium | Low]
- **Deadline**: [If applicable]

## Details
[Detailed information organized with clear sections]

## Dependencies
- [List any dependencies on other teams]
- [Include both blocking and non-blocking]

## Action Items
- [ ] [Specific action required]
- [ ] [Who is responsible]
- [ ] [By when]

## Attachments
- [List of attached documents/artifacts]

## Questions/Clarifications Needed
- [Specific questions requiring answers]
```

### 3. Meeting Protocols

```typescript
export class MeetingProtocol {
  static readonly crossTeamMeeting = {
    preparation: {
      agendaDeadline: '24 hours before',
      materialsDistribution: '12 hours before',
      attendeeConfirmation: '6 hours before',
    },
    
    structure: {
      checkIn: '2 minutes',
      contextSetting: '3 minutes',
      discussionItems: '80% of time',
      actionItems: '10% of time',
      wrapUp: '5 minutes',
    },
    
    outputs: {
      notes: 'Within 1 hour',
      actionItems: 'Immediately',
      recording: 'If applicable',
      followUp: 'As defined',
    },
  };
}
```

## Integration Patterns

### 1. API Contract Negotiation
```typescript
export class APIContractNegotiation {
  async negotiateContract(
    provider: Team,
    consumer: Team,
    requirements: APIRequirements
  ): Promise<APIContract> {
    // Initial proposal from provider
    const proposal = await provider.proposeContract(requirements);
    
    // Consumer review and feedback
    const feedback = await consumer.reviewProposal(proposal);
    
    // Iterative refinement
    let contract = proposal;
    while (!feedback.accepted) {
      contract = await this.refineContract(contract, feedback);
      feedback = await consumer.reviewProposal(contract);
    }
    
    // Finalize and document
    return this.finalizeContract(contract, provider, consumer);
  }
}
```

### 2. Dependency Coordination
```typescript
export class DependencyCoordinator {
  async coordinateDependencies(
    dependencies: Dependency[]
  ): Promise<CoordinationPlan> {
    // Map dependencies to teams
    const teamDependencies = this.mapToTeams(dependencies);
    
    // Create coordination timeline
    const timeline = await this.createTimeline(teamDependencies);
    
    // Identify critical path
    const criticalPath = this.findCriticalPath(timeline);
    
    // Setup monitoring
    const monitoring = await this.setupMonitoring(criticalPath);
    
    return {
      timeline,
      criticalPath,
      monitoring,
      contingencies: this.createContingencies(criticalPath),
    };
  }
}
```

## Common Scenarios

### 1. Feature Integration
- Requirements gathering across teams
- API design collaboration
- Integration testing coordination
- Deployment synchronization

### 2. Incident Response
- Rapid communication protocols
- Clear escalation paths
- Coordinated troubleshooting
- Post-incident reviews

### 3. Performance Optimization
- Metrics sharing
- Bottleneck identification
- Solution collaboration
- Testing coordination

## Success Metrics

### Communication Effectiveness
```typescript
export class CommunicationMetrics {
  static measure(): MetricsReport {
    return {
      responseTime: {
        average: 'Time to first response',
        compliance: '% meeting SLA',
      },
      clarity: {
        clarificationRequests: 'Number of follow-up questions',
        misunderstandings: 'Number of miscommunications',
      },
      efficiency: {
        resolutionTime: 'Time to resolve issues',
        handoffSuccess: 'Successful handoff rate',
      },
      satisfaction: {
        teamSurveys: 'Communication satisfaction scores',
        improvementSuggestions: 'Number of improvement ideas',
      },
    };
  }
}
```

---

*This skill ensures effective collaboration across all PrintCraft AI development teams.*