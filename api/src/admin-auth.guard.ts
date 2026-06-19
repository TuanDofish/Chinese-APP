import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { AuthService } from './auth.service';

@Injectable()
export class AdminAuthGuard implements CanActivate {
  constructor(private readonly authService: AuthService) {}

  async canActivate(context: ExecutionContext) {
    const request = context.switchToHttp().getRequest();
    const token = this.authService.tokenFromAuthorization(
      String(request.headers.authorization || ''),
    );
    request.admin = await this.authService.requireAdmin(token);
    return true;
  }
}
