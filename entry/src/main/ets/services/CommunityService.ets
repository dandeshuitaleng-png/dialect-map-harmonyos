import { common } from '@kit.AbilityKit';
import { CommunityGroup, CommunityMessage } from '../models/DialectModels';
import {
  createLocalCommunityMessage,
  getCommunityGroups as getLocalGroups,
  getCommunityMessages as getLocalMessages,
  storeLocalCommunityMessage,
  CommunityMessageStoreResult
} from './MockCommunityService';

export async function getCommunityGroups(): Promise<CommunityGroup[]> {
  return getLocalGroups();
}

export async function getCommunityMessages(groupId: string): Promise<CommunityMessage[]> {
  return getLocalMessages(groupId);
}

export async function createCommunityMessage(groupId: string, content: string,
  _context: common.UIAbilityContext): Promise<CommunityMessage | undefined> {
  const message = createLocalCommunityMessage(groupId, content, Date.now(),
    new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' }));
  if (message === undefined) return undefined;
  return storeLocalCommunityMessage(message) === CommunityMessageStoreResult.STORED ? message : undefined;
}

export async function toggleGroupMembership(_groupId: string, _userId: string, _joined: boolean): Promise<void> {
  // Membership is kept by Index state for the current local app session.
}

export async function getJoinedGroupIds(): Promise<string[]> {
  return [];
}
