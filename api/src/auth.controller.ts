import {
  Body,
  Controller,
  Get,
  Headers,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { AuthService } from './auth.service';

type AuthBody = {
  email?: string;
  password?: string;
  displayName?: string;
  targetLevel?: string;
};

type GoogleAuthBody = {
  idToken?: string;
  targetLevel?: string;
};

type UserBody = AuthBody & {
  role?: string;
  status?: string;
  avatarUrl?: string;
};

@Controller()
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('auth/register')
  register(@Body() body: AuthBody) {
    return this.authService.register(body);
  }

  @Post('auth/login')
  login(@Body() body: AuthBody) {
    return this.authService.login(body);
  }

  @Post('auth/google')
  googleLogin(@Body() body: GoogleAuthBody) {
    return this.authService.loginWithGoogle(body);
  }

  @Get('auth/me')
  me(
    @Headers('authorization') authorization = '',
    @Query('token') queryToken = '',
  ) {
    return this.authService.me(
      this.authService.tokenFromAuthorization(authorization) || queryToken,
    );
  }

  @Get('admin/users/stats')
  userStats(@Headers('authorization') authorization = '') {
    return this.authService.userStats(
      this.authService.tokenFromAuthorization(authorization),
    );
  }

  @Get('admin/dashboard')
  dashboard(@Headers('authorization') authorization = '') {
    return this.authService.adminDashboard(
      this.authService.tokenFromAuthorization(authorization),
    );
  }

  @Get('admin/users')
  users(@Headers('authorization') authorization = '') {
    return this.authService.listUsers(
      this.authService.tokenFromAuthorization(authorization),
    );
  }

  @Get('admin/users/:id')
  userDetail(
    @Headers('authorization') authorization = '',
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.authService.userDetail(
      this.authService.tokenFromAuthorization(authorization),
      id,
    );
  }

  @Post('admin/users')
  createUser(
    @Headers('authorization') authorization = '',
    @Body() body: UserBody,
  ) {
    return this.authService.createUser(
      this.authService.tokenFromAuthorization(authorization),
      body,
    );
  }

  @Patch('admin/users/:id')
  updateUser(
    @Headers('authorization') authorization = '',
    @Param('id', ParseIntPipe) id: number,
    @Body() body: UserBody,
  ) {
    return this.authService.updateUser(
      this.authService.tokenFromAuthorization(authorization),
      id,
      body,
    );
  }

  @Patch('admin/users/:id/status')
  updateStatus(
    @Headers('authorization') authorization = '',
    @Param('id', ParseIntPipe) id: number,
    @Body() body: { status?: string },
  ) {
    return this.authService.setUserStatus(
      this.authService.tokenFromAuthorization(authorization),
      id,
      String(body.status || 'active'),
    );
  }
}
