#!/bin/bash

# This script generates boilerplate code for all modules
# Run: chmod +x generate-modules.sh && ./generate-modules.sh

echo "🚀 Generating NestJS modules..."

MODULES=(
  "auth"
  "users"
  "products"
  "categories"
  "brands"
  "cart"
  "wishlist"
  "orders"
  "payments"
  "reviews"
  "notifications"
  "flash-sales"
  "promotions"
  "admin"
  "upload"
  "settings"
)

for module in "${MODULES[@]}"; do
  echo "📦 Creating $module module..."

  # Create module file
  cat > "src/modules/$module/$module.module.ts" <<EOF
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ${module^}Controller } from './$module.controller';
import { ${module^}Service } from './$module.service';

@Module({
  imports: [TypeOrmModule.forFeature([])],
  controllers: [${module^}Controller],
  providers: [${module^}Service],
  exports: [${module^}Service],
})
export class ${module^}Module {}
EOF

  # Create controller file
  cat > "src/modules/$module/$module.controller.ts" <<EOF
import { Controller } from '@nestjs/common';
import { ${module^}Service } from './$module.service';

@Controller('$module')
export class ${module^}Controller {
  constructor(private readonly ${module}Service: ${module^}Service) {}

  // TODO: Implement endpoints
}
EOF

  # Create service file
  cat > "src/modules/$module/$module.service.ts" <<EOF
import { Injectable } from '@nestjs/common';

@Injectable()
export class ${module^}Service {
  // TODO: Implement business logic
}
EOF

  echo "✅ $module module created"
done

echo "🎉 All modules generated successfully!"
echo "📝 Next steps:"
echo "1. Implement the business logic in each service"
echo "2. Add endpoints in each controller"
echo "3. Create DTOs for validation"
echo "4. Add authentication guards where needed"
