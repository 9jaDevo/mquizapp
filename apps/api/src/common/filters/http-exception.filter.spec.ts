import { ArgumentsHost, BadRequestException, HttpException, HttpStatus, NotFoundException } from '@nestjs/common';
import { HttpExceptionFilter } from './http-exception.filter';

describe('HttpExceptionFilter', () => {
  let filter: HttpExceptionFilter;

  const buildHost = (): { host: ArgumentsHost; status: jest.Mock; json: jest.Mock } => {
    const status = jest.fn().mockReturnThis();
    const json = jest.fn();
    const response = { status, json };
    const request = { method: 'GET', url: '/test' };
    const host = {
      switchToHttp: () => ({ getResponse: () => response, getRequest: () => request }),
    } as unknown as ArgumentsHost;
    return { host, status, json };
  };

  beforeEach(() => {
    filter = new HttpExceptionFilter();
  });

  it('handles standard HttpException with object response', () => {
    const { host, status, json } = buildHost();
    filter.catch(new BadRequestException({ error: 'INVALID_INPUT', message: 'name required' }), host);
    expect(status).toHaveBeenCalledWith(HttpStatus.BAD_REQUEST);
    expect(json).toHaveBeenCalledWith({
      success: false,
      error: 'INVALID_INPUT',
      message: 'name required',
    });
  });

  it('maps NotFoundException to NOT_FOUND code', () => {
    const { host, status, json } = buildHost();
    filter.catch(new NotFoundException('Missing'), host);
    expect(status).toHaveBeenCalledWith(404);
    expect(json).toHaveBeenCalledWith({ success: false, error: 'NOT_FOUND', message: 'Missing' });
  });

  it('joins array messages from ValidationPipe', () => {
    const { host, json } = buildHost();
    const exc = new HttpException({ message: ['a must be int', 'b must be string'] }, 400);
    filter.catch(exc, host);
    expect(json).toHaveBeenCalledWith({
      success: false,
      error: 'BAD_REQUEST',
      message: 'a must be int; b must be string',
    });
  });

  it('handles non-HttpException errors as 500', () => {
    const { host, status, json } = buildHost();
    filter.catch(new Error('boom'), host);
    expect(status).toHaveBeenCalledWith(500);
    expect(json).toHaveBeenCalledWith({
      success: false,
      error: 'INTERNAL_ERROR',
      message: expect.any(String),
    });
  });
});
