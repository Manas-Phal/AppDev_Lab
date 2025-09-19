import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { LayoutDashboard, CheckSquare, Clock, BarChart3, User } from 'lucide-react';
import { cn } from '@/lib/utils';

const navigationItems = [
  { name: 'Dashboard', path: '/', icon: LayoutDashboard },
  { name: 'Tasks', path: '/tasks', icon: CheckSquare },
  { name: 'Pomodoro', path: '/pomodoro', icon: Clock },
  { name: 'Analytics', path: '/analytics', icon: BarChart3 },
  { name: 'Profile', path: '/profile', icon: User },
];

export default function Navigation() {
  const location = useLocation();

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-background border-t md:relative md:border-t-0 md:border-r md:min-h-screen md:w-64 z-50">
      <div className="flex md:flex-col">
        {/* Logo/Title - hidden on mobile */}
        <div className="hidden md:block p-6 border-b">
          <h2 className="text-xl font-bold bg-gradient-to-r from-primary to-primary/70 bg-clip-text text-transparent">
            Productivity Tracker
          </h2>
        </div>

        {/* Navigation Items */}
        <div className="flex md:flex-col md:p-4 w-full">
          {navigationItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;
            
            return (
              <Link key={item.path} to={item.path} className="flex-1 md:flex-none group">
                <Button
                  variant={isActive ? 'default' : 'ghost'}
                  className={cn(
                    'w-full h-14 md:h-12 md:justify-start rounded-none md:rounded-md md:mb-1',
                    'flex-col md:flex-row gap-1 md:gap-2',
                    'transition-all duration-300 ease-out',
                    'hover:scale-105 hover:shadow-md',
                    isActive && 'bg-primary text-primary-foreground shadow-lg animate-glow',
                    !isActive && 'hover:bg-accent/50 hover:text-accent-foreground'
                  )}
                >
                  <Icon className={cn(
                    "h-5 w-5 transition-all duration-300",
                    "group-hover:scale-110 group-hover:rotate-3",
                    isActive && "animate-float"
                  )} />
                  <span className="text-xs md:text-sm font-medium">{item.name}</span>
                </Button>
              </Link>
            );
          })}
        </div>
      </div>
    </nav>
  );
}
