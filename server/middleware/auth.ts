import {
  verifyToken,
  getTokenFromHeader,
  type JwtPayload,
  type RiderJwtPayload,
} from "../utils/jwt";

declare module "h3" {
  interface H3EventContext {
    user?: JwtPayload;
    rider?: RiderJwtPayload;
  }
}

export default defineEventHandler(async (event) => {
  // Skip auth for public routes
  const publicPaths = [
    "/api/auth/login",
    "/api/auth/rider/login",
    "/api/mobile/auth",
    "/api/mobile/stores",
    "/api/mobile/products",
  ];

  const path = getRequestURL(event).pathname;

  // Skip if not API route
  if (!path.startsWith("/api")) {
    return;
  }

  // Skip public paths
  if (publicPaths.some((p) => path.startsWith(p))) {
    return;
  }

  // Get and verify token
  const token = getTokenFromHeader(event);
  if (!token) {
    return; // Let individual handlers decide if auth is required
  }

  const payload = verifyToken(token);
  if (payload) {
    if ("userId" in payload) {
      event.context.user = payload as JwtPayload;
    } else if ("riderId" in payload) {
      event.context.rider = payload as RiderJwtPayload;
    }
  }
});
