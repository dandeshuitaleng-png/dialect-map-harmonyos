export const XIAOYI_AGENT_ID: string =
  'agent67ed6c01203b437db99567238ebdc976';

export function hasConfiguredXiaoyiAgent(agentId: string): boolean {
  return /^agent[0-9a-f]{32}$/.test(agentId.trim());
}
