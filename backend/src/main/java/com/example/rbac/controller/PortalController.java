package com.example.rbac.controller;

import com.example.rbac.common.R;
import com.example.rbac.service.PortalService;
import com.example.rbac.vo.PortalCockpitVO;
import com.example.rbac.vo.PortalOverviewVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 前台驾驶舱。不挂 @RequiresPerm：任何登录账号都能进大厅，
 * 但舱内数据由 data_scope 在 Service 层过滤，越权时返回 accessible=false 而不是 403。
 */
@RestController
@RequestMapping("/portal")
@RequiredArgsConstructor
public class PortalController {

    private final PortalService portalService;

    @GetMapping("/overview")
    public R<PortalOverviewVO> overview() {
        return R.ok(portalService.overview());
    }

    @GetMapping("/cockpit/{key}")
    public R<PortalCockpitVO> cockpit(@PathVariable String key) {
        return R.ok(portalService.cockpit(key));
    }
}
