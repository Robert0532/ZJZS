package com.example.rbac.security;

import com.example.rbac.entity.SysRole;
import lombok.Data;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Data
public class LoginUser implements Serializable {

    private Long userId;

    private String username;

    private String nickname;

    private Long deptId;

    private String deptName;

    private String status;

    private boolean admin;

    private Set<String> perms = new HashSet<>();

    private Set<String> roles = new HashSet<>();

    private List<SysRole> roleList = new ArrayList<>();

    public boolean hasPerm(String perm) {
        if (admin) {
            return true;
        }
        return perms.contains(perm) || perms.contains("*:*:*");
    }
}
