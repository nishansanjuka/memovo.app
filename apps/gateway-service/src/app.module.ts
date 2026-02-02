import { Module } from '@nestjs/common';
import { ApiModule } from './modules/api/api.module';
import { WebhooksModule } from './modules/webhooks/webhooks.module';
import { ProxyModule } from './modules/proxy/proxy.module';
import { ConfigModule as NestConfigModule } from '@nestjs/config';
import { configuration } from './shared/config';
import { ConfigService } from './shared/services/config.service';

@Module({
  imports: [
    NestConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
    }),
    ProxyModule,
    ApiModule,
    WebhooksModule,
  ],
  controllers: [],
  providers: [ConfigService],
  exports: [ConfigService],
})
export class AppModule {}
