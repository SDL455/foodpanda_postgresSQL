import { writeFile, mkdir } from 'fs/promises'
import { existsSync } from 'fs'
import { join } from 'path'
import { randomUUID } from 'crypto'

export default defineEventHandler(async (event) => {
  try {
    const formData = await readMultipartFormData(event)
    
    if (!formData || formData.length === 0) {
      throw createError({
        statusCode: 400,
        message: 'ບໍ່ພົບໄຟລ໌ທີ່ອັບໂຫຼດ'
      })
    }

    const uploadDir = join(process.cwd(), 'public', 'uploads')
    
    // Create uploads directory if it doesn't exist
    if (!existsSync(uploadDir)) {
      await mkdir(uploadDir, { recursive: true })
    }

    const uploadedFiles: { url: string; name: string }[] = []

    for (const file of formData) {
      if (file.filename && file.data) {
        // Generate unique filename
        const ext = file.filename.split('.').pop() || 'jpg'
        const uniqueName = `${randomUUID()}.${ext}`
        const filePath = join(uploadDir, uniqueName)

        // Write file
        await writeFile(filePath, file.data)

        uploadedFiles.push({
          url: `/uploads/${uniqueName}`,
          name: file.filename
        })
      }
    }

    if (uploadedFiles.length === 0) {
      throw createError({
        statusCode: 400,
        message: 'ບໍ່ສາມາດອັບໂຫຼດໄຟລ໌ໄດ້'
      })
    }

    return {
      success: true,
      files: uploadedFiles
    }
  } catch (error: any) {
    console.error('Upload error:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      message: error.message || 'ເກີດຂໍ້ຜິດພາດໃນການອັບໂຫຼດ'
    })
  }
})
