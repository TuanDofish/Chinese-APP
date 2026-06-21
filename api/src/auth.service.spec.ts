import { UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';

describe('AuthService Google Sign-In', () => {
  const webClientId =
    '567840262106-filnk22a2fdh33vildrem5npg1kb4qmg.apps.googleusercontent.com';
  const androidClientId =
    '567840262106-4snod22r9mcm9gm1g4pbmvlinoufrnib.apps.googleusercontent.com';

  const makeService = () => {
    const users = {
      findOne: jest.fn(),
      create: jest.fn((value) => ({ id: 1, ...value })),
      save: jest.fn(async (value) => value),
    };
    const dataSource = {
      isInitialized: true,
      query: jest.fn(async () => []),
    };
    const verifyIdToken = jest.fn();
    const service = new AuthService(users as never, dataSource as never);
    (service as any).googleClient = { verifyIdToken };
    return { service, users, dataSource, verifyIdToken };
  };

  beforeEach(() => {
    process.env.GOOGLE_OAUTH_CLIENT_IDS = `${webClientId},${androidClientId}`;
  });

  afterEach(() => {
    delete process.env.GOOGLE_OAUTH_CLIENT_IDS;
  });

  it('rejects a forged or invalid Google ID token', async () => {
    const { service, users, verifyIdToken } = makeService();
    verifyIdToken.mockRejectedValue(new Error('invalid token'));

    await expect(
      service.loginWithGoogle({ idToken: 'forged-token' }),
    ).rejects.toBeInstanceOf(UnauthorizedException);
    expect(users.findOne).not.toHaveBeenCalled();
    expect(verifyIdToken).toHaveBeenCalledWith({
      idToken: 'forged-token',
      audience: [webClientId, androidClientId],
    });
  });

  it('creates a user and returns the public auth contract', async () => {
    const { service, users, verifyIdToken } = makeService();
    users.findOne.mockResolvedValue(null);
    verifyIdToken.mockResolvedValue({
      getPayload: () => ({
        email: 'learner@example.com',
        email_verified: true,
        name: 'VNChinese Learner',
        picture: 'https://example.com/avatar.png',
      }),
    });

    const result = await service.loginWithGoogle({
      idToken: 'valid-token',
      targetLevel: 'HSK 2',
    });

    expect(users.create).toHaveBeenCalledWith(
      expect.objectContaining({
        email: 'learner@example.com',
        displayName: 'VNChinese Learner',
        targetLevel: 'HSK 2',
      }),
    );
    expect(result).toEqual(
      expect.objectContaining({
        success: true,
        accessToken: expect.any(String),
        token: expect.any(String),
        user: expect.objectContaining({ email: 'learner@example.com' }),
      }),
    );
    expect(result.accessToken).toBe(result.token);
  });
});
