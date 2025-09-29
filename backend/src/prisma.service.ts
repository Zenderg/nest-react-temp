import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '../generated/prisma';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    try {
      await (this.$connect as () => unknown)();
    } catch (e) {
      console.error('Can`t connect to db: ', e);
    }
  }
}
