import { Controller } from '@nestjs/common';
import { Flash-salesService } from './flash-sales.service';

@Controller('flash-sales')
export class Flash-salesController {
  constructor(private readonly flash-salesService: Flash-salesService) {}

  // TODO: Implement endpoints
}
