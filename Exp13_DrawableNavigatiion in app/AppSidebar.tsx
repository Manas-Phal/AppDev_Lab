import React from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { 
  LayoutDashboard, 
  CheckSquare, 
  Clock, 
  BarChart3, 
  User,
  Menu
} from 'lucide-react';
import {
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarHeader,
  useSidebar,
} from '@/components/ui/sidebar';
import { Button } from '@/components/ui/button';

const navigationItems = [
  { 
    name: 'Dashboard', 
    path: '/', 
    icon: LayoutDashboard,
    description: 'Overview of your productivity'
  },
  { 
    name: 'Tasks', 
    path: '/tasks', 
    icon: CheckSquare,
    description: 'Manage your tasks'
  },
  { 
    name: 'Pomodoro', 
    path: '/pomodoro', 
    icon: Clock,
    description: 'Focus timer sessions'
  },
  { 
    name: 'Analytics', 
    path: '/analytics', 
    icon: BarChart3,
    description: 'Track your progress'
  },
  { 
    name: 'Profile', 
    path: '/profile', 
    icon: User,
    description: 'User settings'
  },
];

export function AppSidebar() {
  const { state, toggleSidebar } = useSidebar();
  const location = useLocation();
  const currentPath = location.pathname;

  const isActive = (path: string) => currentPath === path;
  const isExpanded = navigationItems.some((item) => isActive(item.path));

  return (
    <Sidebar 
      className="border-r border-sidebar-border animate-slide-in-left shadow-sm"
      collapsible="icon"
    >
      <SidebarHeader className="border-b border-sidebar-border p-4 bg-sidebar-background/50">
        <div className="flex items-center gap-3">
          <Button
            variant="ghost" 
            size="icon"
            onClick={toggleSidebar}
            className="hover-lift hover-glow"
          >
            <Menu className="h-5 w-5 icon-bounce" />
          </Button>
          {state === "expanded" && (
            <div className="fade-in-up">
              <h2 className="text-lg font-bold bg-gradient-to-r from-primary via-primary/80 to-primary/60 bg-clip-text text-transparent">
                Productivity Hub
              </h2>
              <p className="text-xs text-sidebar-foreground/60 mt-1">
                Track your progress
              </p>
            </div>
          )}
        </div>
      </SidebarHeader>

      <SidebarContent className="px-2">
        <SidebarGroup>
          <SidebarGroupLabel className="text-sidebar-foreground/70 font-semibold mb-2 px-2">
            Navigation
          </SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu className="space-y-2">
              {navigationItems.map((item, index) => {
                const Icon = item.icon;
                const active = isActive(item.path);
                
                return (
                  <SidebarMenuItem 
                    key={item.path}
                    className="fade-in-up"
                    style={{ animationDelay: `${index * 0.1}s` }}
                  >
                    <SidebarMenuButton 
                      asChild
                      isActive={active}
                      className="hover-lift transition-all duration-300 h-auto p-0"
                    >
                      <NavLink 
                        to={item.path}
                        className={({ isActive }) => 
                          `flex items-center gap-3 p-3 rounded-xl transition-all duration-300 group relative overflow-hidden ${
                            isActive 
                              ? 'bg-primary text-primary-foreground shadow-lg shadow-primary/20' 
                              : 'hover:bg-sidebar-accent/80 hover:text-sidebar-accent-foreground hover:shadow-md'
                          }`
                        }
                      >
                        {/* Background gradient for active state */}
                        {active && (
                          <div className="absolute inset-0 bg-gradient-to-r from-primary to-primary/80 opacity-90" />
                        )}
                        
                        <Icon className={`h-5 w-5 transition-all duration-300 icon-bounce relative z-10 ${
                          active ? 'text-primary-foreground' : 'text-sidebar-foreground group-hover:text-sidebar-accent-foreground'
                        }`} />
                        
                        {state === "expanded" && (
                          <div className="flex flex-col gap-0.5 relative z-10">
                            <span className={`font-medium text-sm ${
                              active ? 'text-primary-foreground' : 'text-sidebar-foreground group-hover:text-sidebar-accent-foreground'
                            }`}>
                              {item.name}
                            </span>
                            <span className={`text-xs transition-colors ${
                              active 
                                ? 'text-primary-foreground/80' 
                                : 'text-sidebar-foreground/60 group-hover:text-sidebar-accent-foreground/70'
                            }`}>
                              {item.description}
                            </span>
                          </div>
                        )}
                        
                        {/* Active indicator */}
                        {active && (
                          <div className="absolute right-2 w-2 h-2 bg-primary-foreground rounded-full animate-pulse" />
                        )}
                      </NavLink>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                );
              })}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
        
        {/* Bottom section with user info when expanded */}
        {state === "expanded" && (
          <div className="mt-auto p-4 border-t border-sidebar-border">
            <div className="flex items-center gap-3 p-3 rounded-xl bg-sidebar-accent/30 hover:bg-sidebar-accent/50 transition-colors duration-300 hover-lift">
              <div className="w-8 h-8 bg-primary rounded-full flex items-center justify-center">
                <User className="h-4 w-4 text-primary-foreground" />
              </div>
              <div className="flex flex-col">
                <span className="text-sm font-medium text-sidebar-foreground">
                  User Profile
                </span>
                <span className="text-xs text-sidebar-foreground/60">
                  Manage settings
                </span>
              </div>
            </div>
          </div>
        )}
      </SidebarContent>
    </Sidebar>
  );
}
