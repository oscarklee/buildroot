#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <stdio.h>

int main(int argc, char* argv[]) {
    SDL_Init(SDL_INIT_VIDEO);
    IMG_Init(IMG_INIT_PNG);

    printf("Driver: %s\n", SDL_GetCurrentVideoDriver());

    SDL_Window* window = SDL_CreateWindow("Test", 0, 0, 1920, 1080, SDL_WINDOW_FULLSCREEN);
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

    SDL_RendererInfo info;
    SDL_GetRendererInfo(renderer, &info);
    printf("Renderer: %s\n", info.name);

    SDL_Surface* surf = (argc > 1) ? IMG_Load(argv[1]) : NULL;
    SDL_Texture* tex = surf ? SDL_CreateTextureFromSurface(renderer, surf) : NULL;

    int x = 0;
    for(int i = 0; i < 300; i++) { // 5 segundos aprox a 60fps
        SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255); // Fondo Azul
        SDL_RenderClear(renderer);

        if(tex) {
            SDL_Rect dst = { 100, 100, 400, 300 };
            SDL_RenderCopy(renderer, tex, NULL, &dst);
        }

        SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255); // Cuadrado Verde Móvil
        SDL_Rect rect = { x % 1920, 500, 100, 100 };
        SDL_RenderFillRect(renderer, &rect);

        SDL_RenderPresent(renderer);
        x += 10;
        SDL_Delay(16);
    }

    SDL_DestroyTexture(tex);
    SDL_FreeSurface(surf);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
