# Super Admin Guide

## Overview
The super admin role provides complete access to all models and administrative functions in the KojAgency platform.

## Super Admin User
- **Email**: imlikeu.io@gmail.com
- **Role**: super_admin
- **Privileges**: Full CRUD operations on ALL models

## Key Features

### 1. User Management
Super admins can:
- Create new users
- Edit existing users (including role assignment)
- Delete users (with safeguards)
- Assign/remove admin and super_admin roles

### 2. Access Control
- Super admins bypass all authorization checks
- Can access all admin panel features
- Can manage sensitive models like User, Lead, etc.

### 3. Safeguards
- Cannot remove own super admin privileges
- Cannot delete the last super admin account
- Cannot delete own account

## Rake Tasks

### Create/Update Super Admin
```bash
rails admin:create_super_admin
```

### List All Admins
```bash
rails admin:list_admins
```

### Downgrade Super Admin (to regular admin)
```bash
EMAIL=user@example.com rails admin:downgrade_super_admin
```

## Code Architecture

### User Model
- Added `super_admin` role to enum (value: 2)
- Methods: `super_admin?`, `can_manage_all?`
- Scopes: `super_admins`, `admins` (includes super admins)

### Authorization
- `Admin::BaseController` - Central authorization logic
- `require_super_admin` - Restricts actions to super admins only
- `authorize_admin_access!` - Allows super admins full access

### Controllers
- `Admin::UsersController` - Full user management (super admin only)
- All admin controllers inherit from `Admin::BaseController`

## Security Notes
1. The super admin password should be changed immediately after first login
2. Use environment variable `SUPER_ADMIN_PASSWORD` in production
3. Limit super admin accounts to trusted administrators only
4. Monitor super admin activity through logs

## Testing
To verify super admin functionality:

1. Sign in with imlikeu.io@gmail.com
2. Navigate to /admin
3. Access Users management section
4. Verify ability to create, edit, and delete users
5. Verify ability to assign roles

## Environment Setup
For production, set:
```bash
SUPER_ADMIN_PASSWORD=your_secure_password_here
```

Then run:
```bash
rails db:seed
# or
rails admin:create_super_admin
```