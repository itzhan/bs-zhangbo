package com.laundry.security;

import com.laundry.entity.SysUser;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public class SecurityUtils {

    public static SysUser getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof SysUser) {
            return (SysUser) auth.getPrincipal();
        }
        return null;
    }

    public static Long getCurrentUserId() {
        SysUser user = getCurrentUser();
        return user != null ? user.getId() : null;
    }

    public static String getCurrentRole() {
        SysUser user = getCurrentUser();
        return user != null ? user.getRole() : null;
    }

    public static boolean isAdmin() {
        return "ADMIN".equals(getCurrentRole());
    }

    public static boolean isRider() {
        return "RIDER".equals(getCurrentRole());
    }

    public static boolean isUser() {
        return "USER".equals(getCurrentRole());
    }
}
