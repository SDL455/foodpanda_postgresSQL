import { successResponse } from "../../utils/response";

export default defineEventHandler(async (event) => {
  // JWT tokens are stateless, so we just return success
  // The client will handle clearing local auth data
  // In a more advanced implementation, you could:
  // 1. Add the token to a blacklist
  // 2. Invalidate refresh tokens in the database
  
  return successResponse(null, "ອອກຈາກລະບົບສຳເລັດ");
});
